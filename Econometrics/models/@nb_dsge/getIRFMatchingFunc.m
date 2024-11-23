function getObjectiveFunc = getIRFMatchingFunc(obj,irfs,weights,normFunc)
% Syntax:
%
% getObjectiveFunc = getIRFMatchingFunc(obj,irfs,weights,normFunc)
%
% Description:
%
% Get objective to minimize when doing IRF matching. 
%
% Input:
%
% - obj      : An object of class nb_dsge.
%
% - irfs     : Same as the irfs output of the nb_model_generic.irf method.
%
% - weights  : Same format as the irfs input. Must provide the same shocks
%              and variables as the irfs input, or else it must be empty
%              (i.e. equal weights). 
%
% - normFunc : A function that maps from R^X -> R, where X is the number
%              of observation of the irf to match. Default is to use
%              @(xw)norm(xw), where xw are the vector of weighted IRFs.
%
% Output:
%
% - getObjectiveFunc : A function handle that can be assign to the
%                      getObjectiveFunc options of the nb_dsge class.
% 
% See also:
% nb_model_generic.irf, nb_dsge.estimate, nb_statespaceEstimator.estimate,
% nb_ts
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handle a scalar nb_dsge object.'])
    end
    if isBreakPoint(obj)
        error([mfilename ':: This method does not handle DSGE models with break points.'])
    end
    
    if ~isstruct(irfs)
        error([mfilename ':: The irfs input must be a struct.'])
    end
    
    if ~nb_isempty(weights)
        if ~isstruct(weights)
            error([mfilename ':: The weights input must be a struct or empty.'])
        end
    end
    
    if ~isa(normFunc,'function_handle')
        error([mfilename ':: The normFunc input must be a function handle!'])
    end
    
    if isempty(obj.options.prior)
        error([mfilename ':: No prior are assign!'])
    end
    dist = cellfun(@func2str,obj.options.prior(:,3),'uniformOutput',false);
    test = strcmpi('nb_distribution.uniform_pdf',dist);
    if any(~test)
        error([mfilename ':: The priors option must select the search area when doing IRF matching. This is done by selecting ',...
                         'a prior on the form {start,lower,upper}. Wrong for the following parameters; ' toString(obj.options.prior(~test,1)')])
    end
    
    % Check steady-state file
    if obj.options.steady_state_solve
        error([mfilename ':: You need to provide a steady-state file to estimate your model. See the ''steady_state_file'' option.'])
    end
    
    if ~isempty(obj.options.steady_state_file)
        if ischar(obj.options.steady_state_file)
            obj.options.steady_state_file = str2func(obj.options.steady_state_file);
        elseif ~isa(obj.options.steady_state_file,'function_handle')
            error([mfilename ':: The steady_state_file option must be set to either a string or a function_handle object.'])
        end
    end
    
    % Return the function that returns the problem to solve in 
    % nb_statespaceEstimator.estimate
    getObjectiveFunc = @(options)getIRFMatchingObjectiveForEstimation(options,irfs,weights,normFunc);
    
    
end

%==========================================================================
function [fh,estStruct,lb,ub,opt,options] = getIRFMatchingObjectiveForEstimation(options,irfs,weights,normFunc)

    % Check the calibration
    parser    = options.parser;
    estimated = nb_statespaceEstimator.checkCalibration(options,parser);

    % Location of the estimated parameters
    [test,indPar] = ismember(estimated,parser.parameters);
    if any(~test)
        error([mfilename ':: The parameter(s) ' toString(estimated(~test)) ' is not part of the model.'])
    end
    
    % Get bounds
    [lb,ub] = nb_statespaceEstimator.getBounds(options);

    % Others
    beta  = options.calibration; % Value of calibrated parameters
    fh    = @irfMatchingObjective;
    init  = options.prior(:,2);
    init  = vertcat(init{:});  
    
    % Optimizer options
    opt = nb_getDefaultOptimset(options.optimset,options.optimizer);
    if isempty(opt.OutputFcn)
        opt.Display = 'iter';
    end
    
    % Get the irfs
    exoNames             = fieldnames(irfs); 
    [t,estStruct.indExo] = ismember(exoNames,parser.exogenous);
    if any(~t)
        error([mfilename ':: The following exogenous variables are given to the irfs input, but are not exogenous '...
               'variables of the model; ' toString(exoNames(~t))])
    end
    
    estStruct.numExo      = length(exoNames);
    endoNames             = irfs.(exoNames{1}).variables; 
    [t,estStruct.indEndo] = ismember(endoNames,parser.endogenous);
    if any(~t)
        error([mfilename ':: The following endogenous variables are given to the irfs input, but are not endogenous '...
               'variables of the model; ' toString(endoNames(~t))])
    end
    
    estStruct.numEndo = length(endoNames);
    estStruct.periods = irfs.(exoNames{1}).numberOfObservations;
    irfsData          = nan(estStruct.numEndo,estStruct.periods,estStruct.numExo);
    for ii = 1:estStruct.numExo
        irfsData(:,:,ii) = transpose(double(irfs.(exoNames{ii})));
    end
    sDateIRFs = irfs.(exoNames{1}).startDate;
    if sDateIRFs == nb_year('0')
        irfsData = irfsData(:,2:end,:); % Remove first obs as it is always 0!
    end
    
    % Weights
    weightsData = ones(estStruct.numEndo,estStruct.periods,estStruct.numExo);
    if ~nb_isempty(weights)
        exoNamesW    = fieldnames(weights);
        [t,indExoW]  = ismember(exoNamesW,exoNames);
        if any(~t)
            error([mfilename ':: The following exogenous variables are given to the weights input, but not the irfs input; '...
                   toString(exoNamesW(~t))])
        end
        endoNamesW   = weights.(exoNamesW{1}).variables; 
        [t,indEndoW] = ismember(endoNamesW,endoNames);
        if any(~t)
            error([mfilename ':: The following endogenous variables are given to the weights input, but not the irfs input; '...
                   toString(endoNamesW(~t))])
        end
        sDate = weights.(exoNamesW{1}).startDate;
        eDate = weights.(exoNamesW{1}).endDate;
        indP  = ((sDate - sDateIRFs) + 1):((eDate - sDateIRFs) + 1);
        for ii = 1:length(exoNamesW)
            weightsData(indEndoW,indP,indExoW(ii)) = transpose(double(weights.(exoNamesW{ii})));
        end
    end
    if sDateIRFs == nb_year('0')
        weightsData       = weightsData(:,2:end,:); % Remove first obs as it is always 0!
        estStruct.periods = estStruct.periods - 1;
    end
    
    % Estimation options
    estStruct.beta      = beta;
    estStruct.estimated = estimated;
    estStruct.indPar    = indPar;
    estStruct.init      = init;
    estStruct.options   = options;
    estStruct.irfs      = irfsData;
    estStruct.weights   = weightsData;
    estStruct.normFunc  = normFunc;

end

%==========================================================================
function fval = irfMatchingObjective(par,estStruct)

    sol = nb_dsge.stateSpace(par,estStruct);
    if ~isempty(sol.err)
        fval = 1e10;
        return
    end
    
    A   = sol.A;
    C   = sol.C(:,estStruct.indExo);
    e   = zeros(estStruct.numExo,1);
    x   = zeros(estStruct.numEndo,estStruct.periods,estStruct.numExo); % IRFs to match
    for ii = 1:estStruct.numExo

        % Set shock to one std (scaled by a parameter)
        e(ii) = 1;
        
        % IRFs
        y         = C*e;
        x(:,1,ii) = y(estStruct.indEndo);
        for tt = 2:estStruct.periods-1
            y          = A*y;
            x(:,tt,ii) = y(estStruct.indEndo);
        end
        
        % Reset innovation
        e(ii) = 0;
        
    end
    
    % Add steady-state
    x = bsxfun(@plus,x,sol.ss(estStruct.indEndo));
    
    % Create the objective to minimize
    diffWIRF             = (x - estStruct.irfs).*estStruct.weights;
    diffWIRF             = diffWIRF(:);        
    notMatched           = isnan(diffWIRF);
    diffWIRF(notMatched) = [];
    fval                 = estStruct.normFunc(diffWIRF);

end
