function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_fmsa.solveRecursive(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Estimation results
    beta = permute(results.beta,[2,1,3]);

    % Get the truly exogenous variables of the model by removing the 
    % predetermined lags from the exogenous variables. The lagged factors
    % are not included here!
    time_trend = opt.time_trend;
    constant   = opt.constant;
    exo        = opt.exogenous;
    dep        = opt.dependent;
    depAll     = nb_cellstrlead(dep,opt.nStep,'varFast');
    if time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if constant
        exo = ['Constant',exo];
    end
    
    % Get the equation y_h = A_h*F + B_h*x + C_h*e
    %---------------------------------------------------

    % The final solution
    nPeriods  = size(beta,3);
    tempSol   = struct();
    tempSol.A = nan(0,0,nPeriods);
    tempSol.B = beta;
    numDep    = length(depAll);
    I         = eye(numDep);
    tempSol.C = I(:,:,ones(1,nPeriods));
    
    % Get the covariance matrix
    vcv = results.sigma;
    
    % Get the ordering
    tempSol.endo       = depAll;
    tempSol.factorsRHS = opt.factorsRHS;
    tempSol.exo        = [exo, opt.factorsRHS];
    tempSol.res        = strcat('E_',depAll);
    tempSol.vcv        = vcv;
    tempSol.class      = 'nb_fmsa';
    tempSol.type       = 'nb';
    
    % Now we need to solve the observation eq part as well, I add the
    % dependent variables to make it generic to favar models
    tempSol.observables = opt.observables;
    tempSol.factors     = opt.factors;
    tempSol.F           = permute(results.lambda(1,:,:),[2,1,3]);
    tempSol.G           = permute(results.lambda(2:end,:,:),[2,1,3]);
    
    % Assume a diagonal variance covariance matrix of the observation eq
    % (This is ok, as each eq is estimated by itself)
    if isfield(results,'R')
        R = results.R;
        for ii = 1:nPeriods
            R(:,:,ii) = diag(diag(R(:,:,ii)));
        end
        tempSol.R = R;
    end
    
end
