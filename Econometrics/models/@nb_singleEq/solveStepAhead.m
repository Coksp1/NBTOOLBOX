function tempSol = solveStepAhead(results,opt)
% Syntax:
%
% tempSol = nb_singleEq.solveStepAhead(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    depAll     = opt.dependent;
    if time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if constant
        exo = ['Constant',exo];
    end
    nExo = length(exo);
    
    leaded = regexp(depAll,'_lead[0-9]*$','match');
    nSteps = nan(1,length(leaded));
    for nn = 1:length(nSteps)
        out        = regexp(leaded{nn},'[0-9]*$','match');
        nSteps(nn) = str2double(out{1});
    end
    maxSteps = max(nSteps);
    allSteps = 1:maxSteps;
    [~,loc]  = ismember(nSteps,allSteps);
    
    % Get expanded vector of left hand side variables
    dep = regexprep(depAll(1),'_lead[0-9]*$',''); % At this point we know it only on leaded dep variable!
    dep = nb_cellstrlead(dep,maxSteps);
    
    % Get the equation y_h = B_h*x + C_h*e
    %---------------------------------------------------
    
    % Then we get the coefficient on the exogenous variables
    B            = zeros(maxSteps,nExo,nPeriods,nQuantiles);
    B(loc,:,:,:) = beta(:,1:nExo,:,:);

    % The final solution
    tempSol   = struct();
    tempSol.A = nan(0,maxSteps,nPeriods,nQuantiles);
    tempSol.B = B;
    I         = eye(numDep);
    tempSol.C = I(:,:,ones(1,nPeriods),ones(1,nQuantiles));
    
    % Get the covariance matrix
    vcv              = eye(numDep);
    vcv              = vcv(:,:,ones(1,nPeriods),ones(1,nQuantiles));
    vcv(loc,loc,:,:) = results.sigma;
    
    % Get the ordering
    tempSol.endo  = dep;
    tempSol.exo   = exo;
    tempSol.res   = strcat('E_',dep);
    tempSol.vcv   = vcv;
    tempSol.class = 'nb_sa';

end
