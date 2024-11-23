classdef nb_dsge < nb_model_generic & nb_model_sampling & nb_model_parse
% Description:
%
% If you use the 'nb_file' you will use the NB Toolbox parser and solver.
% How to write the model file in this case is documented in the DAG.pdf
% file, and there you will also find the documentation of the solution
% algorithm used in this case. See also the nb_dsge.solveNB method.
%
% This class can also be used for converting RISE dsge objects and dynare 
% structures to a nb_model_generic subclass. This makes it for example  
% easy to compare for example IRF's from RISE and dynare with models 
% estimated by the NB TOOLBOX, e.g. VARs. 
%
% It is also possible to give the model files directly to the nb_dsge 
% class by using the 'rise_file' or 'dynare_file' options.
%
% In the case the model is not parsed and solved with NB toolbox credits 
% for solving the DSGE model should go to Junior Maih for his RISE
% toolbox or to the dynare development team, and not to the author of 
% this code.
%
% Superclasses:
%
% nb_model_generic, nb_model_sampling, nb_model_parse
%
% Constructor:
%
%   obj = nb_dsge(varargin)
% 
%   Optional input:
%
%   - See the nb_model_estimate.set method for more.
%
%     See the method assignParameters to assign calibration, and the method
%     assignPosteriorDraws to assign already found posterior draws. If
%     the underlying object is a RISE dsge model, new draws can be made by
%     parameterDraws, if the methods irfs, forecast etc. needs more 
%     draws this will be done automatically. On the other hand if dynare
%     is used this is not possible.
%
%   OR 
%
%   - If the first input is 'rise_file', then the follwing can be given:
%
%       > 'rise_file'            : The filename of the RISE model file.  
%                                  Must return a dsge model. As a string.
%
%       Optional:
%
%       > 'steady_state_file'    : The filename of the steady state file if
%                                  needed. As a string.
%
%       > 'steady_state_imposed' : true (default) or false.
%
%       With this option the RISE model file will be parsed, and a dsge
%       model will be returned. See the method assignParameters to assign
%       calibration, or the method estimate to estimate the model.
%
%   OR
%
%   - If the first input is 'dynare_file':
%
%       > 'dynare_file'          : The filename of the dynare model file.  
%                                  Must return a dsge model. As a string.
%
%       By this options dynare will be runned. This means that all options
%       must be given to the dynare file, such as calibrated parameters or
%       estimation of parameters. If the model is estimated the mode will
%       be used for the parameter values, and the posterior draws will be
%       saved for later used if they are produced. 
%
%       To provide additional inputs when calling the dynare function, use
%       the third input as a one line char with the additional code.
%
%   OR
%
%   - If the first input is 'nb_file':
%
%       > 'nb_file' : The filename of the model file with extension .nb
%                     or .mod.
% 
%       Optional:
%
%       - 'silent'  : See nb_dsge.help('silent')
%
%       Use the set method to set other options found in the options 
%       structure. See nb_dsge.help for more on each option.
%
%       Caution: The observables can be set in a call to the set method, 
%                e.g: set(obj,'observables',{'Var1','Var2'});
%
%   Output:
% 
%   - obj : An nb_dsge object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, nb_dsge.template, nb_dsge.help,
% nb_dsge.solveNB
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties 
        
        % The declared unit root variables. As a struct with fields name, 
        % tex_name and number.
        unitRootVariables   = struct();
        
    end

    properties (Dependent=true)
        
        % The declared observables. As a struct with fields name, tex_name
        % and number.
        observables;
        
    end
    
    properties (Hidden=true)
       
        % Indicator on the need to resolve steady-state or not.
        balancedGrowthSolved    = false;
        
        % Used in the case when unit root variables has been declared.
        % Will be set to true when stationarize is called on the object.
        isStationarized         = false;
        
        % Used in the case that the model is of type NB. E.g. when
        % parameters are set it will re-triggering calculation of
        % derivatives and so forth.
        needToBeSolved          = true;
        
        % For DSGE models solved with the NB Toolbox the observables are
        % being set by the the set method. So we need to store these
        % options somewhere (in the other cases these are stored in the 
        % rise object or dynare structures).
        observablesHidden       = struct('name',{{}},'tex_name', {{}},'number',[]);
        
        % This property is used to make the object portable in DAG when
        % using a steady-state file.
        steadyStateContent      = '';
        
        % Indicator on the need to resolve steady-state or not.
        steadyStateSolved       = false;
        
        % Indicator on the need to re-calculate derivatives or not.
        takenDerivatives        = false;
   
    end
    
    methods
        
        function obj = nb_dsge(varargin)
        % Constructor

            obj            = obj@nb_model_generic();
            temp           = nb_dsge.template();
            temp2          = struct('M_',{[]},'oo_',{[]},'options_',{[]},...
                                    'riseObject',{[]},'data',{[]},'parser',[],...
                                    'dataVariables',{{}},'dataStartDate',{''});
            obj.estOptions = temp2;
            obj.options    = temp;
            
            if nargin == 0
                return
            end
            
            obj.preventSettingData = false;
            if strcmpi(varargin{1},'nb_file')
                
                obj = nb_dsge.parse(varargin{2:end});
            
            elseif strcmpi(varargin{1},'rise_file')
                
                try
                    rise_file = varargin{2};
                catch %#ok<CTCH>
                    error([mfilename ':: If the first input is ''rise_file'' the second input must be provided.'])
                end
                
                obj       = set(obj,varargin{3:end});
                [~,~,ext] = fileparts(rise_file);
                if any(strcmpi(ext,{'.mod','.nb'}))
                    rise_file = nb_dsge.nb2RisePreparser(rise_file,obj.options.silent,obj.options.macroProcessor,obj.options.macroVars);
                end
                
                opt   = obj.options;
                model = rise(rise_file,...
                    'steady_state_file',    opt.steady_state_file,...
                    'steady_state_imposed', opt.steady_state_imposed,...
                    'max_deriv_order',      opt.solve_order);
                
                if ~isa(model,'dsge')
                    error([mfilename ':: The model return by the RISE file is not a DSGE model'])
                end
                obj.estOptions(1).riseObject = model;
                
            elseif any(strcmpi(varargin{1},{'rise_obj','rise_object'}))
                
                try
                    model = varargin{2};
                catch %#ok<CTCH>
                    error([mfilename ':: If the first input is ''rise_obj'' the second input must be provided.'])
                end
                
                if ~isa(model,'dsge')
                    error([mfilename ':: The input given to ''rise_obj'' is not DSGE model'])
                end
                
                obj.estOptions(1).riseObject = model;
                
            elseif strcmpi(varargin{1},'dynare_file')
                
                try
                    dynare_file = varargin{2};
                catch %#ok<CTCH>
                    error([mfilename ':: If the first input is ''dynare_file'' the second input must be provided.'])
                end
                extra = '';
                try %#ok<TRYNC>
                    extra = varargin{3};
                end
                
                % Clear global variables
                clearvars -global
                
                % Refers to the dyn-file
                try
                    eval(['dynare ' dynare_file ' noclearall ' extra]);
                catch Err
                    try
                        run([pwd filesep(), 'nb_nemo_model.m'])
                    catch
                        rethrow(Err)
                    end
                end
                
                % Load the dynare structures
                indExt  = strfind(dynare_file,'.');
                if ~isempty(indExt)
                    dynare_file_short = dynare_file(1,1:indExt(1)-1);
                else
                    dynare_file_short = dynare_file;
                end
                result_file                = [dynare_file_short '_results.mat'];
                loaded                     = load(result_file); 
                obj.estOptions(1).M_       = loaded.M_; 
                obj.estOptions(1).oo_      = loaded.oo_;
                obj.estOptions(1).options_ = loaded.options_;
                
                % Clear global variables
                clearvars -global
                
            else
                obj                       = set(obj,varargin{:});
                obj.estOptions.M_         = obj.options.M_;
                obj.estOptions.oo_        = obj.options.oo_;
                obj.estOptions.options_   = obj.options.options_;
                obj.estOptions.riseObject = obj.options.riseObject;
            end
            
            obj.options = rmfield(obj.options,{'M_','oo_','options_','riseObject'});
            
            % Update the dependent variable names
            if ~nb_isempty(obj.estOptions.M_) % dynare
                
                order                  = obj.estOptions.oo_.dr.order_var;
                obj.dependent.name     = strtrim(cellstr(obj.estOptions.M_.endo_names(order,:)))';
                obj.dependent.tex_name = strrep(obj.dependent.name,'_','\_');
                obj.dependent.number   = length(obj.dependent.name);
                obj.endogenous         = obj.dependent;
                obj.exogenous.name     = strtrim(cellstr(obj.estOptions.M_.exo_names))';
                obj.exogenous.tex_name = strrep(obj.exogenous.name,'_','\_');
                obj.exogenous.number   = length(obj.exogenous.name);
                
                % Get estimation/calibration
                M_          = obj.estOptions.M_;
                res         = struct();
                res.beta    = M_.params;
                res.stdBeta = nan(size(res.beta));
                res.sigma   = M_.Sigma_e;
                obj.results = res;
                
                % Load data from object and check for estimation results
                if isfield(obj.estOptions.options_,'datafile')
                    data = obj.estOptions.options_.datafile;
                    if ~isempty(data)
                        data                           = nb_ts(data);
                        obj.options.data               = data;
                        obj.estOptions.data            = double(data);
                        obj.estOptions.dataVariables   = data.variables;
                        obj.estOptions.dataStartDate   = toString(data.startDate);
                        obj.options.estim_start_date   = data.startDate;
                        obj.options.estim_end_date     = data.startDate + (data.numberOfObservations - 1);
                        obj.results.filterStartDate    = toString(data.startDate);
                        obj.results.filterEndDate      = toString(data.endDate);
                    end

                    % Locate estimation results
                    results = nb_dsge.getDynareEstimationResults(dynare_file_short);
                    if ~nb_isempty(results)
                        if isfield(results,'prior')
                            obj.options.prior    = results.prior;
                            obj.estOptions.prior = results.prior;
                        end
                        if isfield(results,'xparam1')
                            obj.results.xparam1      = results.xparam1;
                            obj.results.param        = results.param;
                            obj.results.stdxparam1   = results.stds;
                            obj.estOptions.estimator = 'nb_dynareEstimator';
                            obj.results.elapsedTime  = nan;
                        end
                        if isfield(results,'xparam1')
                            obj.estOptions.optimizer         = nb_dsge.dynareOptimizer(obj.estOptions.options_.mode_compute);
                            obj.estOptions.estim_start_ind   = obj.estOptions.options_.first_obs;
                            obj.estOptions.estim_end_ind     = obj.estOptions.options_.first_obs + obj.estOptions.options_.nobs - 1;
                            obj.results.includedObservations = obj.estOptions.options_.nobs;
                        end
                        
                    end
                        
                    % Locate the posterior draws (if any)
                    posterior = nb_dsge.dynareToPosterior(dynare_file_short);

                    % Locate filtered variables
                    obj.results = nb_dsge.dynareGetFiltered(obj.results,obj.estOptions.oo_);

                    % Save the posterior draws to a .mat file
                    obj.estOptions.pathToSave = nb_saveDraws(obj.name,posterior);
                    
                end
                
            elseif ~isempty(obj.estOptions.riseObject) % RISE
                
                obj.dependent.name     = obj.estOptions.riseObject.endogenous.name;
                obj.dependent.tex_name = obj.estOptions.riseObject.endogenous.tex_name;
                obj.dependent.number   = length(obj.dependent.name);
                obj.endogenous         = obj.dependent;
                obj.exogenous.name     = obj.estOptions.riseObject.exogenous.name;
                obj.exogenous.tex_name = obj.estOptions.riseObject.exogenous.tex_name;
                obj.exogenous.number   = length(obj.exogenous.name);
                
                % Get estimation/calibration
                model    = obj.estOptions.riseObject;
                res      = struct();
                res.beta = model.parameter_values;
                if nb_isempty(model.estimation)
                    res.stdBeta = nan(size(res.beta));
                else
                    res.stdBeta = model.estimation.posterior_maximization.mode_stdev;
                end
                res.sigma   = nan(0,1);
                obj.results = res;
                
                % Load data from object
                data = model.options.data;
                if ~nb_isempty(data)
                    if isa(data,'ts')
                        dataT = double(data);
                        if ~isempty(dataT)
                            obj.options.data = nb_ts(data);
                        end
                    else
                        obj.options.data = nb_RISEtsStruct2nb_ts(data);
                    end
                    obj.estOptions.data = double(obj.options.data);
                    if ~isempty(obj.estOptions.data)
                        obj.estOptions.dataVariables = obj.options.data.variables;
                        obj.estOptions.startDate     = toString(obj.options.data.startDate);
                    end
                end
                    
            end
            obj.preventSettingData = true;
            
        end
        
        function propertyValue = get.observables(obj)
           
            if isNB(obj)
                propertyValue = obj.observablesHidden;
            elseif isRise(obj)
                obs           = obj.estOptions.riseObject.observables.name;
                propertyValue = struct('name',      {obs},...
                                       'tex_name',  {strrep(obs,'_','\_')},...
                                       'number',    length(obs));
            elseif nb_isempty(obj.estOptions.options_) % No model file has been parsed, return empty
                propertyValue = struct('name',      {{}},...
                                       'tex_name',  {{}},...
                                       'number',    []);
            else % Dynare
                obs           = cellstr(obj.estOptions.options_.varobs)';
                propertyValue = struct('name',      {obs},...
                                       'tex_name',  {strrep(obs,'_','\_')},...
                                       'number',    length(obs));
            end
            
        end
        
        function obj = set.observables(obj,propertyValue)
            obj.observablesHidden = propertyValue;
        end
        
    end
    
    methods (Hidden=true)
        
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'DSGE';
            
        end
        
        varargout = createEstOptionsStruct(varargin)
        function obj = indicateResolve(obj)
            obj.balancedGrowthSolved = false;
            obj.isStationarized      = false;
            obj.needToBeSolved       = true;
            obj.steadyStateSolved    = false;
            obj.takenDerivatives     = false;
        end
        
    end
    
    methods(Access=protected)
       
        function param = getParametersNames(obj)
            
            if isDynare(obj)
                M_      = obj.estOptions.M_;
                param   = struct('name',               {strtrim(cellstr(M_.param_names))},...
                                 'value',              obj.results.beta);
            elseif isRise(obj)
                riseObj = obj.estOptions.riseObject;
                param   = struct('name',                {riseObj.parameters.name'},...
                                 'value',               obj.results.beta,...
                                 'is_switching',        riseObj.parameters.is_switching',...
                                 'is_trans_prob',       riseObj.parameters.is_trans_prob',...
                                 'is_measurement_error',riseObj.parameters.is_measurement_error',...
                                 'governing_chain',     riseObj.parameters.governing_chain');
            elseif isNB(obj)
                
                if ~isfield(obj.estOptions.parser,'parameters_tex_name')
                    obj.estOptions.parser.parameters_tex_name = strrep(obj.estOptions.parser.parameters,'_','\_');
                end
                param = struct('name',          {obj.estOptions.parser.parameters'},...
                               'tex_name',      {obj.estOptions.parser.parameters_tex_name'},...
                               'value',         obj.results.beta,...
                               'isInUse',       obj.estOptions.parser.parametersInUse,...
                               'isUncertain',   obj.estOptions.parser.parametersIsUncertain);
            else
                param = struct('name',{{}},'value',[]);
            end
            
        end
        
        varargout = solveNB(varargin)
        varargout = wrapUpEstimation(varargin); 
        
    end
    
    methods (Access=private)
       
        varargout = callDynareFilter(varargin)
        varargout = callNBFilter(varargin)
        varargout = callRISEFilter(varargin)
        varargout = checkModelEqs(varargin)
        varargout = checkObsModelEqs(varargin)
        varargout = createEqFunction(varargin)
        varargout = fullSolution(varargin)
        varargout = obsModel2func(varargin)
        varargout = realTimeFilterEngine(varargin)
        varargout = updateGivenOptimalPolicy(varargin);
        varargout = updateObject(varargin);
        
    end
    
    methods(Static=true)
        varargout = addObsModelSolver(varargin)
        varargout = backwardSolver(varargin)
        varargout = expectedBreakPointSolver(varargin)
        varargout = findAniticipatedMatrices(varargin)
        varargout = getObjectiveForEstimation(varargin)
        varargout = getOptimalMonetaryPolicyMatrices(varargin)
        varargout = help(varargin)
        varargout = interpretStochasticTrendInit(varargin)
        varargout = kleinSolver(varargin)
        varargout = likelihood(varargin)
        varargout = looseOptimalMonetaryPolicySolver(varargin)
        varargout = makeObservationEq(varargin)
        varargout = nb2RisePreparser(varargin)
        varargout = optimalMonetaryPolicySolver(varargin)
        varargout = parse(varargin)
        varargout = printOSR(varargin)
        varargout = objective(varargin)
        varargout = rationalExpectationSolver(varargin)
        varargout = solveBreakPoints(varargin)
        varargout = solveNormal(varargin)
        varargout = solveOneIteration(varargin)
        varargout = solveOneRegime(varargin)
        varargout = solveExpanded(varargin)
        varargout = solveForEpilogue(varargin)
        varargout = solveRecursive(varargin)
        varargout = stateSpace(varargin)
        varargout = stateSpaceBreakPoint(varargin)
        varargout = stateSpaceTVP(varargin)
        varargout = structuralMatrices2JacobianNB(varargin);
        varargout = systemPriorObjective(varargin)
        varargout = template(varargin)
        varargout = updateSolution(varargin)
    end
    
    methods(Static=true,Hidden=true)
        varargout = assignSteadyState(varargin)
        varargout = checkSteadyStateStatic(varargin)
        varargout = calculateLossDiscretion(varargin)
        varargout = calculateLossCommitment(varargin)
        varargout = derivativeLossFunction(varargin)
        varargout = derivativeNB(varargin)
        varargout = fillAuxiliarySteadyState(varargin)
        varargout = getBreakPoint(varargin)
        varargout = getBreakPointParameters(varargin)
        varargout = getBreakTimingParameters(varargin)
        varargout = getHorizon(varargin)
        varargout = getObsOrderingNB(varargin)
        varargout = getOrderingNB(varargin)
        varargout = getSteadyStateExo(varargin)
        varargout = getStatesOfBreakPoint(varargin)
        varargout = getTimeVarying(varargin)
        varargout = jacobian2StructuralMatricesNB(varargin)
        varargout = interpretSteadyStateChange(varargin)
        varargout = interpretSteadyStateInput(varargin)
        varargout = lineError(varargin)
        varargout = resolveDynare(varargin)
        varargout = setDiscount(varargin)
        varargout = solveInnerFixedPoint(varargin)
        varargout = solveSteadyStateStatic(varargin);
        varargout = transLeadLag(varargin)
        
        function parser = getDefaultParser()
            
            parser = struct(...
                'breakPoints',[],...
                'equations',{{}},...
                'obs_equations',{{}},...
                'constraints',{{}},...
                'createStatic',true,...
                'endogenous',{{}},...
                'obs_endogenous',{{}},...
                'all_endogenous',{{}},...
                'exogenous',{{}},...
                'obs_exogenous',{{}},...
                'all_exogenous',{{}},...
                'file','',...
                'growth',{{}},...
                'growthLoc',[],...
                'hasExpectedBreakPoints',false,...
                'nBreaks',0,...
                'observables',{{}},...
                'parameters',{{}},...
                'parametersStatic',{{}},...
                'parameterization',struct,...
                'reporting',struct,...
                'static',{{}},...
                'staticEquations',{{}},...
                'staticLoc',[],...
                'steadyStateFirstUsed',false,...
                'steadyStateInitUsed',false,...
                'steady_state_model',struct(),...
                'unitRootVars',{{}});
        
        end
        
        function matches = getUniqueMatches(eqs,varargin)
            
            eqs     = nb_dsge.transLeadLagStatic(eqs);
            matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*','match');
            matches = unique(horzcat(matches{:}));
            func    = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?=\()','match');%(?!\()
            func    = unique(horzcat(func{:}));
            func    = strrep(func,'(','');
            indFunc = ismember(matches,func);
            matches = matches(~indFunc);
            
            if nargin > 1
                
                for ii = 1:length(varargin)
                    ind     = ismember(matches,varargin{ii});
                    matches = matches(~ind);
                end
                
            end
            
        end
        
        function prefix = growthPrefix()
            prefix = 'D_Z_';
        end
        
        function prefix = steadyStateInitPostfix()
            prefix = '_SS_INIT';
        end
        
        function prefix = steadyStateFirstPostfix()
            prefix = '_SS_FIRST';
        end
        
    end
    
    methods(Static=true,Access=private)
        varargout = addAuxiliaryLagVariables(varargin)
        varargout = addMultipliers(varargin)
        varargout = applyDiscount(varargin)
        varargout = curvatureEvaluator(varargin)
        varargout = dynareGetFiltered(varargin)
        varargout = dynareOptimizer(varargin)
        varargout = dynareToPosterior(varargin)
        varargout = eqs2func(varargin)
        varargout = eqs2funcSub(varargin)
        varargout = getDynareEstimationResults(varargin)
        varargout = getLeadLag(varargin)
        varargout = getLeadLagCore(varargin)
        varargout = getLeadLagObsModel(varargin)
        varargout = getStaticEquations(varargin)
        varargout = parseGrowth(varargin)
        varargout = parseLossFunction(varargin)
        varargout = parseSimpleRules(varargin)
        varargout = removeUnitRootVariables(varargin)
        varargout = selectSolveAlgorithm(varargin)
        varargout = simulateStructuralMatricesStatic(varargin)
        varargout = solveAndCalculateLoss(varargin)
        varargout = solveAndCalculateLossUncertain(varargin)
        varargout = solveSimpleRule(varargin)
        varargout = ssStruct2ssDouble(varargin)
        varargout = transLeadLagStatic(varargin)
        varargout = updateClassifications(varargin)
        varargout = updateDrOrder(varargin)
        varargout = updateDynamicOrder(varargin)
        varargout = updateLeadLagGivenOptimalPolicy(varargin)
        
        function breakPoint = createDefaultBreakPointStruct()
            breakPoint = struct(...
                'parameters',       {{}},...
                'values',           [],...
                'date',             '',...
                'steady_state_exo', [],...
                'expectedDate',     '');
        end
        
        function firstMatches = getFirstMatches(eqs,varargin)
            
            eqs          = nb_dsge.transLeadLagStatic(eqs);
            firstMatches = cell(length(eqs),1);
            for ii = 1:length(eqs)
                matches = regexp(eqs{ii},'[A-Za-z_]{1}[A-Za-z_0-9]*','match');
                func    = regexp(eqs{ii},'[A-Za-z_]{1}[A-Za-z_0-9]*(?=\()','match');%(?!\()
                func    = unique(func);
                func    = strrep(func,'(','');
                indFunc = ismember(matches,func);
                matches = matches(~indFunc);
            
                if nargin > 1

                    for jj = 1:length(varargin)
                        ind     = ismember(matches,varargin{jj});
                        matches = matches(~ind);
                    end

                end
                firstMatches{ii} = matches{1};
                
            end
            
        end
        
    end
         
end

