function tempSol = solveNormal(results,opt,ident)
% Syntax:
%
% tempSol = nb_var.solveNormal(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    maxLag = max(opt.maxLagLength + 1,opt.nLags + 1);

    % Provide solution
    dep = opt.dependent;
    if isfield(opt,'block_exogenous')
        dep = [dep,opt.block_exogenous];
    end
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
        
        tempSol.A = results.T;
        nLags     = size(tempSol.A,2)/numDep;
        nPeriods  = size(tempSol.A,3);
        numRows   = (nLags - 1)*numDep;
        tempSol.B = zeros(numDep*nLags,length(exo),nPeriods);
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
    
        % Estimation results
        beta = results.beta';
        
        % Seperate the coefficients of the exogenous and the predetermined lags
        if nb_isempty(opt.prior)
            bayesianMF = false; 
        else
            bayesianMF = any(strcmpi(opt.prior.type,nb_var.mfPriors()));
        end

        if strcmpi(opt.estim_method,'ml') || bayesianMF
            nExo     = length(exo);
            predBeta = beta(:,nExo+1:end);
            beta     = beta(:,1:nExo);
        else
            pred     = nb_cellstrlag(dep,maxLag,'varFast');
            ind      = ~ismember(exo,pred);
            exo      = exo(ind); % Remove lagged dependent from rhs variables in estimation
            predBeta = beta(:,~ind);
            beta     = beta(:,ind);
        end

        % Get the equation y = A*y_1 + B*x + C*e
        % for the dynamic system
        %------------------------------------------

        % The final solution
        numDep = length(dep);
        if isempty(predBeta)
            tempSol.A = [];
            tempSol.B = beta;
            numRows   = 0;
            nLags     = 0;
        else
            nLags     = size(predBeta,2)/length(dep);
            numRows   = (nLags - 1)*numDep;
            tempSol   = struct();
            tempSol.A = [predBeta;eye(numRows),zeros(numRows,numDep)];
            tempSol.B = [beta;zeros(numRows,length(exo))];
        end
        vcv = results.sigma;
        
    end
    
    if isfield(ident,'stabilityTest')
        if ident.stabilityTest
            [~,~,modulus] = nb_calcRoots(tempSol.A);
            if any(modulus > 1)
                error([mfilename ': The model is not stable. I.e. all the roots are not inside the unit circle.'])
            end
        end
    end
    
    % Identification of the VAR
    res     = strcat('E_',dep);
    counter = [];
    if nb_isempty(ident)
        tempSol.C = [eye(numDep);zeros(numRows,numDep)];
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
                tempSol.C = [C(indI,indI);zeros(numRows,numDep)];
                
            case 'combination'
                
                S                = nb_var.ABidentification(ident,tempSol.A,vcv,ident.maxDraws,ident.draws);
                tempSol.C        = [S.W;zeros(numRows,numDep,1,ident.draws)];
                shocks           = ident.shocks;
                nShocks          = length(shocks);
                res(1,1:nShocks) = shocks;
                counter          = S.counter;
                
            otherwise
                 error([mfilename ':: Unsupported identification type ' ident.type])
        end
        
        % The shocks are standardized, so set covariance matrix to eye.
        vcv = eye(size(vcv));
         
    end
    
    % Get the ordering
    tempSol.endo           = [dep,nb_cellstrlag(dep,nLags-1,'varFast')];
    tempSol.exo            = exo;
    tempSol.obs            = dep;
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
