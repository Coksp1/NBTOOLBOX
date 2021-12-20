function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_midas.solveRecursive(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
 
    % Estimation results
    beta = permute(results.beta,[2,1,3]);

    % Get the truly exogenous variables of the model by removing the 
    % predetermined lags from the exogenous variables. The lagged factors
    % are not included here!
    constant   = double(opt.constant);
    exo        = opt.exogenous;
    depAll     = nb_cellstrlead(opt.dependent,opt.nStep);
    if constant
        exo = ['Constant',exo];
    end
    
    % Get the equation y_h = B_h*x + C_h*e
    %---------------------------------------------------
    nPeriods = size(beta,3);
    
    % Get dynamics
    if opt.AR
        A    = beta(:,constant+1,:);
        beta = [beta(:,1:constant,:),beta(:,constant+2:end,:)]; % Remove AR coeff
    else
        A = nan(size(beta,1),0,nPeriods);
    end
    
    % Then we get the coefficient on the exogenous variables
    if ~strcmpi(opt.algorithm,'beta')
        B = beta;
    else
        B = beta(:,1:end-3,:);
    end
    
    % The final solution
    tempSol   = struct();
    tempSol.A = A;
    tempSol.B = B;
    numDep    = length(depAll);
    I         = eye(numDep);
    tempSol.C = I(:,:,ones(1,nPeriods));
    
    % Get the covariance matrix
    vcv = results.sigma;
    
    % Get the ordering
    tempSol.endo  = depAll;
    tempSol.exo   = exo;
    tempSol.res   = strcat('E_',depAll);
    tempSol.vcv   = vcv;
    tempSol.class = 'nb_midas';
    tempSol.type  = 'nb';
    
end
