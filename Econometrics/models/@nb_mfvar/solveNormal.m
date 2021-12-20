function tempSol = solveNormal(results,opt,ident)
% Syntax:
%
% tempSol = nb_mfvar.solveNormal(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    % Provide solution
    dep  = opt.dependent;
    if isfield(opt,'block_exogenous')
        dep = [dep,opt.block_exogenous];
    end
    obs = dep;
    dep = dep(~opt.indObservedOnly);
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
        tempSol.H = results.Z;
        nStates   = size(tempSol.H,2)/nDep;
        vcv       = results.Q;
        
        % Now we need to solve the observation eq part as well, I add the
        % dependent variables to make it generic to favar models
        tempSol.observables = dep;
        tempSol.factors     = strcat('AUX_',dep);
        tempSol.F           = results.C;
        tempSol.G           = results.Z;
        tempSol.S           = results.S; % To do re-standardization later, if empty no need
        tempSol.R           = results.R; % Measurment error covariance matrix
        
        
    else
        % Get the equation y = A*y_1 + B*x + C*e
        % for the dynamic system
        %------------------------------------------

        % Estimation results
        beta = results.beta';
        
        % Get measurment equation
        tempSol   = struct();
        tempSol.H = nb_mlEstimator.getMeasurmentEqMFVAR(opt);
        tempSol.H = permute(tempSol.H,[1,2,4,3]);
        nStates   = size(tempSol.H,2)/nDep;
        
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
    res     = strcat('E_',dep);
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
    
    % Get the ordering
    auxDep                 = strcat('AUX_',dep);
    tempSol.endo           = [auxDep,nb_cellstrlag(auxDep,nStates-1,'varFast')];
    tempSol.exo            = exo;
    tempSol.obs            = obs;
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
