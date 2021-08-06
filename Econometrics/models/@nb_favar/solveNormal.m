function tempSol = solveNormal(results,opt,ident)
% Syntax:
%
% tempSol = nb_favar.solveNormal(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    maxLag = max(opt.maxLagLength,opt.nLags);

    % Estimation results
    beta = results.beta';

    % Provide solution
    dep  = opt.dependent;
    if isfield(opt,'block_exogenous')
        dep = [dep,opt.block_exogenous];
    end
    exo  = opt.exogenous;
    if opt.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if opt.constant
        exo = ['Constant',exo];
    end
    
    % Remove the predetermined lags from the
    % exogenous variables. The lagged factors
    % are not included here!
    pred = nb_cellstrlag(dep,maxLag,'varFast');
    ind  = ~ismember(exo,pred);
    exo  = exo(ind);
    
    % Get the equation y = A*y_1 + B*x + C*e
    % for the dynamic system
    %------------------------------------------
    
    % Seperate the coefficients of the 
    % exogenous and the predetermined lags
    nFactRHS = length(opt.factorsRHS);
    factBeta = beta(:,end-nFactRHS+1:end);
    beta     = beta(:,1:end-nFactRHS);
    predBeta = [beta(:,~ind),factBeta];
    beta     = beta(:,ind);
    depAll   = [dep,opt.factors];
    nLags    = size(predBeta,2)/length(depAll);
    
    % Reorder the VAR, so the variables run fast
    allLagsOld = [nb_cellstrlag(dep,nLags,'varFast'),opt.factorsRHS];
    allLags    = nb_cellstrlag(depAll,nLags,'varFast');
    [~,ind]    = ismember(allLags,allLagsOld);
    predBeta   = predBeta(:,ind);
    
    % The final solution
    numDep    = length(depAll);
    numRows   = (nLags - 1)*numDep;
    tempSol   = struct();
    tempSol.A = [predBeta;eye(numRows),zeros(numRows,numDep)];
    tempSol.B = [beta;zeros(numRows,length(exo))];
    
    % Identification of the VAR
    res     = strcat('E_',depAll);
    counter = [];
    if nb_isempty(ident)
        tempSol.C = [eye(numDep);zeros(numRows,numDep)];
        vcv       = results.sigma;
    else
        
        switch lower(ident.type)
            
            case 'cholesky'
                
                order     = ident.ordering;
                [~,ind]   = ismember(order,depAll);
                sigma     = results.sigma;
                sigma     = sigma(ind,ind);
                C         = chol(sigma,'lower');
                [~,indI]  = ismember(depAll,order);
                tempSol.C = [C(indI,indI);zeros(numRows,numDep)];
                
            case 'combination'
                
                S                = nb_var.ABidentification(ident,tempSol.A,results.sigma,ident.maxDraws,ident.draws);
                tempSol.C        = [S.W;zeros(numRows,numDep,1,ident.draws)];
                shocks           = ident.shocks;
                nShocks          = length(shocks);
                res(1,1:nShocks) = shocks;
                counter          = S.counter;
                
            otherwise
                 error([mfilename ':: Unsupported identification type ' ident.type])
        end
        
        vcv = eye(size(results.sigma));
         
    end
    
    % Get the ordering
    tempSol.endo           = [depAll,nb_cellstrlag(depAll,nLags-1,'varFast')];
    tempSol.exo            = exo;
    tempSol.obs            = depAll;
    tempSol.res            = res;
    tempSol.vcv            = vcv;
    tempSol.identification = ident;
    tempSol.counter        = counter;
    tempSol.class          = 'nb_favar';
    tempSol.type           = 'nb';
    
    % Now we need to solve the observation eq part as well
    tempSol.observables = [opt.observables,opt.observablesFast];
    order               = [opt.factors,dep];
    wanted              = [dep,opt.factors];
    [~,ind]             = ismember(wanted,order);
    tempSol.factors     = wanted;
    tempSol.F           = results.lambda(1,:)';
    G                   = results.lambda(2:end,:)';
    tempSol.G           = G(:,ind);
    
    % Assume a diagonal variance covariance matrix of the observation eq
    % (This is ok, as each eq is estimated by itself)
    tempSol.R = diag(diag(results.R));
    
end
