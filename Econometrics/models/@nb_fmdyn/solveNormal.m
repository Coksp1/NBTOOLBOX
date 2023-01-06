function tempSol = solveNormal(results,options)
% Syntax:
%
% tempSol = nb_fmdyn.solveNormal(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % The final solution
    nRec      = size(results.T,3);
    tempSol   = struct();
    tempSol.A = results.T;
    tempSol.B = zeros(size(results.T,1),size(results.C,2),nRec);
    if strcmpi(options.estim_method,'tvpmfsv')
        tempSol.C   = [eye(options.nFactors); zeros(size(results.T,1) - options.nFactors, options.nFactors)];
        tempSol.C   = tempSol.C(:,:,ones(1,nRec));
        tempSol.vcv = results.Q;
    else
        tempSol.C   = results.BQ;
        tempSol.vcv = eye(size(tempSol.C,2));
        tempSol.vcv = tempSol.vcv(:,:,ones(1,nRec));
    end
    
    % Get exo names
    exo = options.exogenous;
    if options.time_trend
       exo = ['time_trend',exo]; 
    end
    if options.constant
       exo = ['constant',exo]; 
    end
    
    % Get states
    [stateNames,resNames] = nb_tvpmfsvEstimator.getStateNames(options);
    
    % Get the ordering
    tempSol.endo  = stateNames;
    tempSol.exo   = exo;
    tempSol.res   = resNames;
    tempSol.class = 'nb_fmdyn';
    tempSol.type  = 'nb';
    
    % Now we need to solve the observation eq part as well, I add the
    % dependent variables to make it generic to favar models
    tempSol.observables = options.observables;
    tempSol.factors     = stateNames;
    tempSol.F           = results.C;
    tempSol.G           = results.Z;
    tempSol.S           = results.S; % To do re-standardization later, if empty no need
    tempSol.R           = results.R; % Measurement error covariance matrix
    if isfield(results,'P')
        tempSol.P = results.P; % One-step ahead forecast error variance
    end
    if options.setRToZero
        tempSol.R = zeros(size(tempSol.R));
    end
    
    % Calibrated measurement error covariance matrix
    if ~isempty(options.calibrateR) && isfield(tempSol,'R')
        tempSol = calibrateR(tempSol,options,tempSol.observables);
    end
    
end

function tempSol = calibrateR(tempSol,options,obs)

    % Calibrated measurement equation
    nPeriods       = size(tempSol.R,3);
    tempSol.RCalib = tempSol.R;
    vars           = options.calibrateR(1:2:end);
    R_scale        = [options.calibrateR{2:2:end}];
    if length(vars) ~= length(R_scale)
        error('The calibrateR option must have even numbered length.')
    end
    [test,loc] = ismember(vars,obs);
    if any(~test)
        error(['You cannot calibrate the measurement error on ',...
            'the following variables ' toString(vars(~test))])
    end
    [~,locY] = ismember(vars,options.dataVariables);
    sample   = options.estim_start_ind:options.estim_end_ind;
    Y        = options.data(sample,locY);
    if options.recursive_estim
        start = options.recursive_estim_start_ind - options.estim_start_ind;
    else
        start = size(Y,1) - 1;
    end
    for ii = 1:nPeriods
        tempSol.RCalib(loc,loc,ii) = diag(nanvar(Y(1:start+ii,:))./R_scale);
    end
    
end  
