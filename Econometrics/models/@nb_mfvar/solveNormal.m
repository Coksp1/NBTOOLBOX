function tempSol = solveNormal(results,opt,ident)
% Syntax:
%
% tempSol = nb_mfvar.solveNormal(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    % Provide solution
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
    
    if strcmpi(opt.estim_method,'tvpmfsv')
        
        tempSol.A = results.T;
        nLags     = size(tempSol.A,2)/nDep;
        nPeriods  = size(tempSol.A,3);
        numRows   = (nLags - 1)*nDep;
        tempSol.B = zeros(nDep*nLags,nExo,nPeriods);
        vcv       = results.Q;
        
        % Now we need to solve the observation eq part as well, I add the
        % observables to make it generic to favar models
        tempSol.factors     = strcat('AUX_',obs);
        tempSol.F           = results.C;
        tempSol.G           = results.Z;
        tempSol.S           = results.S; % To do re-standardization later, if empty no need
        tempSol.P           = results.P; % One-step ahead forecast error variance
        nStates             = size(tempSol.G,2)/nDep;
        if isfield(opt,'mixingSettings')
            % Set all elements but the high frequency mixing variables to
            % zero during forecasting 
            tempSol.R            = results.R;
            loc0                 = setdiff(1:size(tempSol.R,1),opt.mixingSettings.loc);
            tempSol.R(loc0,loc0) = 0;
        else
            tempSol.R = zeros(size(results.Z,1)); % Turn of measurement error during forecasting
        end
        
        if ~nb_isempty(opt.measurementEqRestriction)
            % We only add support for measurement restrictions post
            % estimation
            
            % Get time-varying measurement equations
            [tempSol.G,yRest] = nb_bVarEstimator.applyMeasurementEqRestriction(tempSol.G,[],opt);
            numObsBefore      = length(obs);
            obs               = [obs,{opt.measurementEqRestriction.restricted}];
            tempSol.G         = tempSol.G(:,:,end);
            
            % Get weighted parameters in F
            numRest = length(obs) - numObsBefore;
            weights = nan(numRest,nDep);
            for ii = 1:nDep
                weights(:,ii) = sum(tempSol.G(numObsBefore+1:end,ii:nDep:end),2);
            end
            FRest     = weights*tempSol.F(1:nDep,:);
            tempSol.F = [tempSol.F;FRest];
            
            % Append measurement error covariance matrix
            numObs                = length(obs);
            R                     = zeros(numObs,numObs);
            locR                  = 1:numObsBefore;
            R(locR,locR)          = tempSol.R;
            R_scale               = [opt.measurementEqRestriction.R_scale];
            locRRest              = numObsBefore+1:numObs;
            R(locRRest,locRRest)  = diag(nanvar(yRest)./R_scale);
            tempSol.R             = R;
            tempSol.observables   = obs;
            
        end
        
    else
        % Get the equation y = A*y_1 + B*x + C*e
        % for the dynamic system
        %------------------------------------------

        % Estimation results
        beta = results.beta';
        
        % Get measurement equation
        tempSol   = struct();
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
        
        % Seperate the coefficients of the 
        % exogenous and the predetermined lags
        predBeta = beta(:,nExo+1:end);
        beta     = beta(:,1:nExo);
        nLags    = size(predBeta,2)/length(dep);
        nExtra   = nStates - nLags; 

        % The final solution
        numRows   = (nStates - 1)*nDep;
        predBeta  = [predBeta,zeros(nDep,nExtra*nDep)];
        tempSol.A = [predBeta;eye(numRows),zeros(numRows,nDep)];
        tempSol.B = [beta;zeros(numRows,length(exo))];
        vcv       = results.sigma;
        if isfield(ident,'stabilityTest')
            if ident.stabilityTest
                [~,~,modulus] = nb_calcRoots(tempSol.A);
                if any(modulus > 1)
                    error([mfilename ': The model is not stable. I.e. all the roots are not inside the unit circle.'])
                end
            end
        end
    end
    
    % Identification of the VAR
    counter = [];
    if nb_isempty(ident)
        tempSol.C = [eye(nDep);zeros(numRows,nDep)];
    else
        
        switch lower(ident.type)
            
            case 'cholesky'
                
                order     = ident.ordering;
                [~,ind]   = ismember(order,dep);
                if any(ind == 0)
                    error([mfilename ':: Identification failed. The following variables are not part of the model; ' toString(order(ind==0))])
                end
                sigma     = vcv;
                sigma     = sigma(ind,ind);
                C         = chol(sigma,'lower');
                [~,indI]  = ismember(dep,order);
                tempSol.C = [C(indI,indI);zeros(numRows,nDep)];
                
            case 'combination'
                
                S                = nb_var.ABidentification(ident,tempSol.A,vcv,ident.maxDraws,ident.draws);
                tempSol.C        = [S.W;zeros(numRows,nDep,1,ident.draws)];
                shocks           = ident.shocks;
                nShocks          = length(shocks);
                res(1,1:nShocks) = shocks;
                counter          = S.counter;
                
            otherwise
                 error([mfilename ':: Unsupported identification type ' ident.type])
        end
        
        vcv = eye(size(vcv));
         
    end
    
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
    if size(tempSol.RCalib,2) > 1
        tempSol.RCalib(loc,loc) = diag(nanvar(Y)./R_scale);
    else
        tempSol.RCalib(loc) = nanvar(Y)./R_scale;
    end
end
