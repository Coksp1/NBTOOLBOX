function [fh,estStruct,lb,ub,opt,options] = getObjectiveForEstimation(options,forSystemPrior)
% Syntax:
%
% [fh,estStruct,lb,ub,opt,options] = ...
%               nb_dsge.getObjectiveForEstimation(options,forSystemPrior)
%
% Description:
%
% Get objective to minimize. Used by the nb_statespaceEstimator.estimate
% function.
%
% See also:
% nb_dsge.estimate, nb_statespaceEstimator.estimate
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        forSystemPrior = false;
    end
    
    if options.parser.nBreaks > 0
        if ~options.estim_steady_state_solve
            error([mfilename ':: The estim_steady_state_solve option must be set to true if you have added break point(s).'])
        end
    end
    
    % Load the data on the observables
    %----------------------------------
    parser = options.parser;
    if ~forSystemPrior
        [y,options] = nb_statespaceEstimator.loadData(options,parser);
        if isempty(y)
            error([mfilename ':: No observables has been declared.'])
        end
    else
        y = [];
    end
    
    % Check the calibration
    %------------------------------------------------------
    estimated = nb_statespaceEstimator.checkCalibration(options,parser);
    
    % Get the estimation options
    %------------------------------------------------------
    if isempty(parser.all_endogenous)
        endo = parser.endogenous;
    else
        endo = parser.all_endogenous;
    end
    [test,obsInd] = ismember(parser.observables,endo);
    if any(~test)
        error([mfilename ':: The following observables is not part of the model; ' toString(parser.observables(~test)) '.'])
    end
    if length(parser.exogenous) < length(parser.observables)
        error([mfilename ':: The number of exogenous variables (' int2str(length(parser.exogenous)) ') are less than ',...
              'the number of observables (' int2str(length(parser.observables)) ').'])
    end
    
    % Break point parameters
    [options,isBreakP,isTimeOfBreakP,states,filterType] = nb_dsge.getBreakPoint(options);
    
    % Are we dealing with time-varying parameters given by some
    % time-series?
    if options.stochasticTrend
        filterType = 4;
    end
    [indTimeVarying,timeVarying,filterType] = nb_dsge.getTimeVarying(options,parser,filterType);
    
    
    % Location of the rest
    [~,indPar] = ismember(estimated(~isBreakP & ~isTimeOfBreakP),parser.parameters);
    
    % Get bounds
    if nargout > 2
        [lb,ub] = nb_statespaceEstimator.getBounds(options);
    end
    
    % Others
    beta = options.calibration; % Value of calibrated parameters
    fh   = str2func([options.class '.objective']);
    if isempty(options.prior)
        init = [];
    else
        init = options.prior(:,2);
        init = vertcat(init{:});  
    end
    
    % Optimizer options
    if nargout > 4
        opt = nb_getDefaultOptimset(options.optimset,options.optimizer);
    end
    
    % Estimation options
    if isfield(options,'estim_verbose')
        estim_verbose = options.estim_verbose;
    else
        estim_verbose = false;
    end
    
    estStruct = struct(...
        'beta',             beta,...        
        'estimated',        {estimated},...
        'estim_verbose',    estim_verbose,...
        'indPar',           indPar,...
        'indTimeVarying',   indTimeVarying,...
        'init',             init,...
        'isBreakP',         isBreakP,...
        'isTimeOfBreakP',   isTimeOfBreakP,...
        'obsInd',           obsInd,...
        'options',          options,...
        'states',           states,...
        'timeVarying',      timeVarying,...
        'filterType',       filterType,...
        'y',                y,...
        'z',                []);
    
end
