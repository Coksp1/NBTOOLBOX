function tempSol = solveRecursive(results,opt,ident)
% Syntax:
%
% tempSol = nb_var.solveRecursive(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    % Get model settings
    maxLag = max(opt.maxLagLength + 1,opt.nLags + 1);
    
    if strcmpi(opt.estim_method,'tvpmfsv')
        [auxDep,res] = nb_tvpmfsvEstimator.getStateNames(opt);
        dep          = regexprep(auxDep(1:size(res,2)),'^AUX\_','');
    else
        dep  = opt.dependent;
        if isfield(opt,'block_exogenous')
            dep = [dep,opt.block_exogenous];
        end
        res = strcat('E_',dep);
    end
    obs = dep;
    
    exo = opt.exogenous;
    if opt.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if opt.constant
        exo = ['Constant',exo];
    end
    
    numDep  = length(dep);
    tempSol = struct();
    if strcmpi(opt.estim_method,'tvpmfsv')
        
        A        = results.T;
        nLags    = size(A,2)/numDep;
        nPeriods = size(A,3);
        numRows  = (nLags - 1)*numDep;
        B        = zeros(numDep*nLags,length(exo),nPeriods);
        vcv      = results.Q;
        
        % Now we need to solve the observation eq part as well, I add the
        % dependent variables to make it generic to favar models
        tempSol.observables = dep;
        tempSol.factors     = strcat('AUX_',dep);
        tempSol.F           = results.C;
        tempSol.G           = results.Z;
        tempSol.S           = results.S; % To do re-standardization later, if empty no need
        tempSol.R           = zeros(size(results.Z,1),size(results.Z,1),size(results.Z,3)); % Turn of measurement error during forecasting
        tempSol.P           = results.P; % One-step ahead forecast error variance
        
        if ~nb_isempty(opt.measurementEqRestriction)
            % We only add support for measurement restrictions post
            % estimation
            
            % Get time-varying measurement equations
            [tempSol.G,yRest] = nb_bVarEstimator.applyMeasurementEqRestriction(tempSol.G,[],opt);
            obs               = [obs,{opt.measurementEqRestriction.restricted}];
            numObs            = length(obs);
            tempSol.G         = tempSol.G(:,:,end-nPeriods+1:end);
                        
            % Get weighted parameters in F
            F = nan(numObs,size(tempSol.F,2),nPeriods);
            for ii = 1:nPeriods
                weights   = tempSol.G(numDep+1:end,1:numDep,ii);
                FRest     = weights*tempSol.F(:,:,ii);
                F(:,:,ii) = [tempSol.F(:,:,ii);FRest];
            end
            tempSol.F = F;    
            
            % Append measurement error covariance matrix
            R       = zeros(numObs,1,nPeriods);
            R_scale = [opt.measurementEqRestriction.R_scale];
            start   = opt.recursive_estim_start_ind - opt.estim_start_ind;
            for ii = 1:nPeriods   
                R(numDep+1:end,:,ii) = nanvar(yRest(1:start+ii,:))./R_scale;
            end
            tempSol.R = R;
            
        end
        tempSol.observables = obs;
        
    else
        % Estimation results
        beta = permute(results.beta,[2,1,3]);

        % Seperate the coefficients of the exogenous and the predetermined lags
        if isempty(opt.prior)
            priorType = '';
        else
            priorType = opt.prior.type;
        end
        if strcmpi(opt.estim_method,'ml') || any(strcmpi(priorType,nb_var.mfPriors()))
            nExo     = length(exo);
            predBeta = beta(:,nExo+1:end,:);
            beta     = beta(:,1:nExo,:);
        else
            pred     = nb_cellstrlag(dep,maxLag,'varFast');
            ind      = ~ismember(exo,pred);
            exo      = exo(ind); % Remove lagged dependent from rhs variables in estimation
            predBeta = beta(:,~ind,:);
            beta     = beta(:,ind,:);
        end

        % Get the equation y = A*y_1 + B*x + C*e
        % for the dynamic system
        %------------------------------------------
        nPeriods = size(beta,3);
        nLags    = size(predBeta,2)/numDep;
        numRows  = (nLags - 1)*numDep;
        I        = eye(numRows);
        I        = I(:,:,ones(1,nPeriods));
        A        = [predBeta;I,zeros(numRows,numDep,nPeriods)];
        B        = [beta;zeros(numRows,length(exo),nPeriods)];
        vcv      = results.sigma;
        
        if ~nb_isempty(opt.measurementEqRestriction)
            tempSol = appendMeasurementRest(tempSol,opt,results,obs,numDep,numRows,nPeriods);
        end
        
    end
        
    % Identification of the VAR
    counter = [];
    if nb_isempty(ident)
        C   = [eye(numDep);zeros(numRows,numDep)];
        C   = C(:,:,ones(1,nPeriods));
    else

        switch lower(ident.type)

            case 'cholesky'

                order    = ident.ordering;
                [~,indO] = ismember(order,dep);
                [~,indI] = ismember(dep,order);
                if any(indO == 0)
                    error([mfilename ':: Identification failed. The following variables are not part of the model; ' toString(order(ind==0))])
                end
                C = zeros(numRows + numDep,numDep,nPeriods);
                for ii = 1:nPeriods
                    sigma     = vcv(:,:,ii);
                    sigma     = sigma(indO,indO);
                    CT        = chol(sigma,'lower');
                    C(:,:,ii) = [CT(indI,indI);zeros(numRows,numDep)];
                end

            case 'combination'

                counter = nan(1,nPeriods);
                C       = zeros(numRows + numDep,numDep,nPeriods,ident.draws);
                
                % Create waiting bar window
                h      = nb_waitbar([],'Identification',nPeriods,true);
                h.text = 'Starting...'; 
                
                for ii = 1:nPeriods
                    
                    S           = nb_var.ABidentification(ident,A(:,:,ii),vcv(:,:,ii),ident.maxDraws,ident.draws);
                    C(:,:,ii,:) = [S.W;zeros(numRows,numDep,1,ident.draws)];
                    counter(ii) = S.counter;
                    
                    if h.canceling
                        error([mfilename ':: User terminated'])
                    end

                    h.status = ii;
                    h.text   = ['Finished with ' int2str(ii) ' recursive periods...'];
                    
                end
                shocks           = ident.shocks;
                nShocks          = length(shocks);
                res(1,1:nShocks) = shocks;

                % Delete the waitbar.
                delete(h) 
                
            otherwise
                 error([mfilename ':: Unsupported identification type ' ident.type])
        end
        
        % The shocks are standardized, so set covariance matrix to eye.
        vcv = eye(size(vcv(:,:,1)));
        vcv = vcv(:,:,ones(1,nPeriods));
        
    end
    
    tempSol.A = A;
    tempSol.B = B;
    tempSol.C = C;
    
    % Calibrate measurement error covariance matrix
    if ~isempty(opt.calibrateR) && isfield(tempSol,'R')
        tempSol = calibrateR(tempSol,opt,tempSol.observables);
    end

    % Get the ordering
    if strcmpi(opt.estim_method,'tvpmfsv')
        tempSol.endo = auxDep;
    else
        tempSol.endo = [dep,nb_cellstrlag(dep,nLags-1,'varFast')];
    end
    tempSol.exo            = exo;
    tempSol.obs            = obs;
    tempSol.res            = res;
    tempSol.vcv            = vcv;
    tempSol.identification = ident;
    tempSol.counter        = counter;
    if isfield(opt,'class')
        tempSol.class = opt.class;
    else
        tempSol.class = 'nb_var';
    end
    tempSol.type = 'nb';

end

%==========================================================================
function tempSol = appendMeasurementRest(tempSol,opt,results,obs,numDep,numRows,nPeriods)

    tempSol.G           = [eye(numDep),zeros(numDep,numRows)];
    [tempSol.G,yRest]   = nb_bVarEstimator.applyMeasurementEqRestriction(tempSol.G,[],opt);
    tempSol.G           = permute(tempSol.G,[1,2,4,3]);
    obs                 = [obs,{opt.measurementEqRestriction.restricted}];
    tempSol.observables = obs;
    
    % Measurement error covariance matrix
    if ~isfield(results,'R')
        numObs    = length(obs);
        tempSol.R = zeros(numObs,1,nPeriods);
        R_scale   = [opt.measurementEqRestriction.R_scale];
        start     = opt.recursive_estim_start_ind - opt.estim_start_ind;
        for ii = 1:nPeriods   
            tempSol.R(numDep+1:end,:,ii) = nanvar(yRest(1:start+ii,:))./R_scale;
        end
    else
        tempSol.R = results.R;
    end
       
end

%==========================================================================
function tempSol = calibrateR(tempSol,opt,obs)

    % Calibrate measurement equation
    nPeriods       = size(tempSol.R,3);
    tempSol.RCalib = tempSol.R;
    vars           = opt.calibrateR(1:2:end);
    R_scale        = [opt.calibrateR{2:2:end}];
    if length(vars) ~= length(R_scale)
        error('The calibrateR option must have even numbered length.')
    end
    [test,loc] = ismember(vars,obs);
    if any(~test)
        error(['You cannot calibrate the measurement error on ',...
            'the following variables ' toString(vars(~test))])
    end
    [~,locY] = ismember(vars,opt.dataVariables);
    sample   = opt.estim_start_ind:opt.estim_end_ind;
    Y        = opt.data(sample,locY);
    start    = opt.recursive_estim_start_ind - opt.estim_start_ind;
    if size(tempSol.RCalib,2) > 1
        for ii = 1:nPeriods
            tempSol.RCalib(loc,loc,ii) = diag(nanvar(Y(1:start+ii,:))./R_scale);
        end
    else
        for ii = 1:nPeriods
            tempSol.RCalib(loc,:,ii) = nanvar(Y(1:start+ii,:))./R_scale;
        end
    end
    
end  
