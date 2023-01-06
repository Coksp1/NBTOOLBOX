function tempSol = solveRecursive(results,opt,ident)
% Syntax:
%
% tempSol = nb_mfvar.solveRecursive(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    % Get model settings
    if strcmpi(opt.estim_method,'tvpmfsv')
        % Here we must make sure that we order the low frequency variables
        % last. This is not returned by nb_tvpmfsvEstimator.getStateNames,
        % as the opt.observables are reorder back to user defined order!
        % opt.reorderLoc stores the ordering based on frequency!
        [auxDep,res] = nb_tvpmfsvEstimator.getStateNames(opt);
        obs          = opt.observables;
        res          = res(opt.reorderLoc(~opt.indObservedOnly));
        auxDep       = auxDep(opt.reorderLoc(~opt.indObservedOnly));
        dep          = regexprep(auxDep,'^AUX\_','');
    else
        dep  = opt.dependent;
        if isfield(opt,'block_exogenous')
            dep = [dep,opt.block_exogenous];
        end
        obs    = dep;
        dep    = dep(~opt.indObservedOnly);
        res    = strcat('E_',dep);
        auxDep = strcat('AUX_',dep);
    end
    
    exo = opt.exogenous;
    if opt.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if opt.constant
        exo = ['Constant',exo];
    end
    nDep = length(dep);
    nExo = length(exo);
    
    tempSol = struct();
    if strcmpi(opt.estim_method,'tvpmfsv')
        A        = results.T;
        nLags    = size(A,2)/nDep;
        nPeriods = size(A,3);
        numRows  = (nLags - 1)*nDep;
        B        = zeros(nDep*nLags,nExo,nPeriods);
        vcv      = results.Q;
        
        % Now we need to solve the observation eq part as well, I add the
        % dependent variables to make it generic to favar models
        tempSol.factors     = strcat('AUX_',obs);
        tempSol.F           = results.C;
        tempSol.G           = results.Z;
        tempSol.S           = results.S; % To do re-standardization later, if empty no need
        tempSol.P           = results.P; % One-step ahead forecast error variance
        nStates             = size(tempSol.G,2)/nDep;
        if isfield(opt,'mixingSettings')
            % Set all elements but the high frequency mixing variables to
            % zero during forecasting 
            tempSol.R              = results.R;
            loc0                   = setdiff(1:size(tempSol.R,1),opt.mixingSettings.loc);
            tempSol.R(loc0,loc0,:) = 0;
        else
            tempSol.R = zeros(size(results.Z,1),size(results.Z,1),size(results.Z,3)); % Turn of measurement error during forecasting
        end
        
        if ~nb_isempty(opt.measurementEqRestriction)
            % We only add support for measurement restrictions post
            % estimation
            
            % Get time-varying measurement equations
            [tempSol.G,yRest] = nb_bVarEstimator.applyMeasurementEqRestriction(tempSol.G(:,:,end),[],opt);
            numObsBefore      = length(obs);
            obs               = [obs,{opt.measurementEqRestriction.restricted}];
            numObs            = length(obs);
            tempSol.G         = tempSol.G(:,:,end-nPeriods+1:end);
            
            % Get weighted parameters in F
            numRest = length(obs) - numObsBefore;
            F       = nan(numObs,size(tempSol.F,2),nPeriods);
            for ii = 1:nPeriods
                weights = nan(numRest,nDep);
                for jj = 1:nDep
                    weights(:,jj) = sum(tempSol.G(numObsBefore+1:end,jj:nDep:end,ii),2);
                end
                FRest     = weights*tempSol.F(1:nDep,:,ii);
                F(:,:,ii) = [tempSol.F(:,:,ii);FRest];
            end
            tempSol.F = F;
            
            % Append measurement error covariance matrix
            R              = zeros(numObs,numObs,nPeriods);
            locR           = 1:numObsBefore;
            R(locR,locR,:) = tempSol.R;
            R_scale        = [opt.measurementEqRestriction.R_scale];
            locRRest       = numObsBefore+1:numObs;
            start          = opt.recursive_estim_start_ind - opt.estim_start_ind;
            for ii = 1:nPeriods   
                R(locRRest,locRRest,ii) = diag(nanvar(yRest(1:start+ii,:))./R_scale);
            end
            tempSol.R           = R;
            tempSol.observables = obs;
            
        end
        
    else
        
        % Get measurement equation
        tempSol = struct();
        if ~nb_isempty(opt.measurementEqRestriction)
            indObservedOnlyAll  = opt.indObservedOnly;
            opt.indObservedOnly = indObservedOnlyAll(1:size(opt.frequency,2));
        end
        tempSol.G = nb_mlEstimator.getMeasurementEqMFVAR(opt);
        if ~nb_isempty(opt.measurementEqRestriction)
            opt.indObservedOnly = indObservedOnlyAll;
            tempSol.G           = nb_bVarEstimator.applyMeasurementEqRestriction(tempSol.G,[],opt);
            obs                 = [obs,{opt.measurementEqRestriction.restricted}];
        end
        tempSol.G = permute(tempSol.G,[1,2,4,3]);
        nStates   = size(tempSol.G,2)/nDep;
        tempSol.R = results.R; % Measurement error covariance matrix

        % Get the equation y = A*y_1 + B*x + C*e
        % for the dynamic system
        %------------------------------------------

        % Seperate the coefficients of the 
        % exogenous and the predetermined lags
        beta     = permute(results.beta,[2,1,3]);
        nPeriods = size(beta,3);
        predBeta = beta(:,nExo+1:end,:);
        beta     = beta(:,1:nExo,:);
        nLags    = size(predBeta,2)/length(dep);
        nExtra   = nStates - nLags; 

        % The final solution
        numRows  = (nStates - 1)*nDep;
        I        = eye(numRows);
        I        = I(:,:,ones(1,nPeriods));
        predBeta = [predBeta,zeros(nDep,nExtra*nDep,nPeriods)];
        A        = [predBeta;I,zeros(numRows,nDep,nPeriods)];
        B        = [beta;zeros(numRows,length(exo),nPeriods)];
        if ~nb_isempty(ident)
            if isfield(ident,'ordering')
                order     = ident.ordering;
                [~,indO]  = ismember(order,dep);
                [~,indI]  = ismember(dep,order);
            end
        end
        vcv = results.sigma;
        
    end

    % Identification of the VAR
    counter = [];
    if nb_isempty(ident)
        C   = [eye(nDep);zeros(numRows,nDep)];
        C   = C(:,:,ones(1,nPeriods));
    else

        switch lower(ident.type)

            case 'cholesky'

                C = zeros(numRTot,nDep,nPeriods);
                for ii = 1:nPeriods
                    sigma     = vcv(:,:,ii);
                    sigma     = sigma(indO,indO);
                    CT        = chol(sigma,'lower');
                    C(:,:,ii) = [CT(indI,indI);zeros(numRows,nDep)];
                end

            case 'combination'

                counter = nan(1,nPeriods);
                C       = zeros(numRTot,nDep,nPeriods,ident.draws);
                
                % Create waiting bar window
                h      = nb_waitbar([],'Identification',nPeriods,true);
                h.text = 'Starting...'; 
                
                for ii = 1:nPeriods
                    
                    S           = nb_var.ABidentification(ident,A(:,:,ii),vcv(:,:,ii),ident.maxDraws,ident.draws);
                    C(:,:,ii,:) = [S.W;zeros(numRows,nDep,1,ident.draws)];
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
        
        vcv = eye(size(vcv(:,:,1)));
        vcv = vcv(:,:,ones(1,nPeriods));
        
    end
    
    tempSol.A = A;
    tempSol.B = B;
    tempSol.C = C;

    % Calibrate measurement error covariance matrix
    if ~isempty(opt.calibrateR) && isfield(tempSol,'R')
        tempSol = calibrateR(tempSol,opt,obs);
    end
    
    % Get the ordering
    tempSol.endo           = [auxDep,nb_cellstrlag(auxDep,nStates-1,'varFast')];
    tempSol.exo            = exo;
    tempSol.obs            = obs;
    tempSol.observables    = obs;
    tempSol.res            = res;
    tempSol.vcv            = vcv;
    tempSol.identification = ident;
    tempSol.counter        = counter;
    if isfield(opt,'class')
        tempSol.class = opt.class;
    else
        tempSol.class = 'nb_mfvar';
    end
    tempSol.type = 'nb';

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
