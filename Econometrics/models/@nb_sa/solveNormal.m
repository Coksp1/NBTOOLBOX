function tempSol = solveNormal(results,opt)
% Syntax:
%
% tempSol = nb_sa.solveNormal(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Estimation results
    beta       = permute(results.beta,[2,1,3,4]); % numDep x nExo x nPeriods x nQuantiles
    numDep     = size(beta,1);
    nPeriods   = size(beta,3);
    nQuantiles = size(beta,4);
    
    % Get the truly exogenous variables of the model by removing the 
    % predetermined lags from the exogenous variables. The lagged factors
    % are not included here!
    time_trend = opt.time_trend;
    constant   = opt.constant;
    exo        = opt.exogenous;
    dep        = opt.dependent;
    if time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if constant
        exo = ['Constant',exo];
    end
    nExo = length(exo);
    
    % Get the equation y_h = B_h*x + C_h*e
    %---------------------------------------------------

    leaded   = ~any(cellfun(@isempty,regexp(dep,'_lead[0-9]*$','match')));
    depClean = unique(regexprep(dep,'_lead[0-9]*$',''));
    if leaded && length(depClean) == 1
        tempSol = nb_singleEq.solveStepAhead(results,opt);
        return
    end
    
    % The final solution
    tempSol   = struct();
    tempSol.A = nan(0,numDep,nPeriods,nQuantiles);
    tempSol.B = beta(:,1:nExo,:,:);
    tempSol.C = repmat(eye(numDep),[1,1,nPeriods,nQuantiles]);
    
    % Get the covariance matrix
    vcv = results.sigma;
    
    % Get the ordering
    tempSol.endo  = dep;
    tempSol.exo   = exo;
    tempSol.res   = strcat('E_',dep);
    tempSol.vcv   = vcv;
    tempSol.class = 'nb_sa';
    tempSol.type  = 'nb';
    
end
