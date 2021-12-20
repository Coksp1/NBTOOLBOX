function tempSol = solveNormal(results,opt)
% Syntax:
%
% tempSol = nb_fmdyn.solveNormal(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % The final solution
    nRec        = size(results.T,3);
    tempSol     = struct();
    tempSol.A   = results.T;
    tempSol.B   = zeros(size(results.T,1),size(results.C,2),nRec);
    if strcmpi(opt.estim_method,'tvpmfsv')
        tempSol.C   = [eye(opt.nFactors); zeros(size(results.T,1) - opt.nFactors, opt.nFactors)];
        tempSol.C   = tempSol.C(:,:,ones(1,nRec));
        tempSol.vcv = results.Q;
    else
        tempSol.C   = results.BQ;
        tempSol.vcv = eye(size(tempSol.C,2));
        tempSol.vcv = tempSol.vcv(:,:,ones(1,nRec));
    end
    
    % Get exo names
    exo = opt.exogenous;
    if opt.time_trend
       exo = ['time_trend',exo]; 
    end
    if opt.constant
       exo = ['constant',exo]; 
    end
    
    % Get states
    [stateNames,resNames] = nb_tvpmfsvEstimator.getStateNames(opt);
    
    % Get the ordering
    tempSol.endo  = stateNames;
    tempSol.exo   = exo;
    tempSol.res   = resNames;
    tempSol.class = 'nb_fmdyn';
    tempSol.type  = 'nb';
    
    % Now we need to solve the observation eq part as well, I add the
    % dependent variables to make it generic to favar models
    tempSol.observables = opt.observables;
    tempSol.factors     = stateNames;
    tempSol.F           = results.C;
    tempSol.G           = results.Z;
    tempSol.S           = results.S; % To do re-standardization later, if empty no need
    tempSol.R           = results.R; % Measurment error covariance matrix
    
end
