function [irfs,irfsBands,plotter,obj] = irf(obj,varargin)
% Syntax:
%
% [irfs,irfsBands,plotter] = irf(obj,varargin)
%
% Description:
%
% Create impulse responses of the given vector of nb_model_generic objects
% 
% Caution : If recursive estimation is done, only the last estimated model
%           will be used.
%
% Input:
%         
% - obj         : A vector of nb_model_generic objects
% 
% Optional input:
%
% - 'addSS'          : Set to false to not add the steady-state to IRF
%                      of nb_dsge objects.
%
% - 'compare'        : Give true if you have a scalar nb_dsge model and 
%                      you want to graph the irfs from the different 
%                      regimes from a NBToolbox solved model against 
%                      eachother. Default is false.
%
% - 'compareShocks'  : Give true if you want to plot all the IRFs of
%                      different shocks in the same graphs (one separate
%                      graph for each variable). In this case you need a
%                      scalar nb_model_generic object as the obj input!
%
%                      Use the graphSubPlots method or the  
%                      nb_graphSubPlotGUI class to produce the graphs in 
%                      this case.
%
% - 'compareVars'    : Give true if you want to plot all the IRFs of
%                      different variables in the same graphs (one separate
%                      graph for each shock). In this case you need a
%                      scalar nb_model_generic object as the obj input!
%
%                      Use the graphSubPlots method or the  
%                      nb_graphSubPlotGUI class to produce the graphs in 
%                      this case.
%
% - 'continue'       : true or false. If true it will continue from a
%                      paused call to this method, or else it will
%                      start from the beginning. 
%
%                      Caution : All the inputs will be taken from the
%                                paused run!
%
% - 'cores'          : The number of cores to open, as an integer. Default
%                      is to open max number of cores available. Only an 
%                      option if either 'parallel' or 'parallelL' is set 
%                      to true.
%
% - 'draws'          : Number of draws for calculating girf. Default is
%                      1000. For Markov switching models this will set the 
%                      number of simulated paths of states. For more see  
%                      the 'type' input.
%
% - 'factor'         : A cell array with the factors to multiply the
%                      irf of the indiviual model variables.
%                      I.e. {'var1',100,...} or 
%                      {{'var1','var2'},100,...}
%
%                      If the string starts with a asterisk you will 
%                      multiply all the variables that contain that 
%                      string with the given factor.
%                      E.g. {'*_GAP',100}
%
% - 'fanPerc'        : This options sets the error band percentiles of the 
%                      graph, when the 'perc' input is empty. As a 1 x 
%                      numErrorBand double. E.g. [0.3,0.5,0.7,0.9]. 
%                      Default is 0.68.
%
% - 'foundReplic'    : A struct with size 1 x replic. Each element
%                      must be on the same format as obj.solution. I.e.
%                      each element must be the solution of the model
%                      given a set of drawn parameters. See the 
%                      parameterDraws method of the nb_model_generic class.
%
%                      Caution: You still need to set 'parameterDraws'
%                               to the number of draws you want to do.
%
% - 'irfCompare'     : A struct on the same format as the irfs output from
%                      this function with the IRFs to compare to. 
%
% - 'levelMethod'    : One of the following:
%
%      > 'cumulative product'               : cumprod(1 + X,1)
% 
%      > 'cumulative sum'                   : cumsum(X,1)
% 
%      > 'cumulative product (log)'         : log(cumprod(1 + X,1))
% 
%      > 'cumulative sum (exponential)'     : exp(cumsum(X,1))
% 
%      > 'cumulative product (%)'           : cumprod(1 + X/100,1)
% 
%      > 'cumulative sum (%)'               : cumsum(X/100,1)
% 
%      > 'cumulative product (log) (%)'     : log(cumprod(1 + X/100,1))
% 
%      > 'cumulative sum (exponential) (%)' : exp(cumsum(X/100,1))
% 
%      > '4 period growth (log approx)'     : nb_msum(X,3)
%
% - 'method'         : The selected method to create error bands.
%                      Default is ''. See help on the method input of the
%                      nb_model_generic.parameterDraws method for more 
%                      this input. An extra option is:
%                                        
%                      > 'identDraws' : Uses the draws of the matrix with
%                        the map from structural shocks to dependent 
%                        variables. See nb_var.set_identification. Of 
%                        course this option only makes sence for VARs 
%                        identified with sign restrictions.
%  
% - 'normalize'      : A 1 x 3 cell. First element must be the variable 
%                      name as a string. The second element must be the
%                      value to normalize to, as an integer. While the
%                      third element is the period to be normalized, if 
%                      set to inf, it will normalize the max impact 
%                      period.
%
%                      E.g. {'Var',1,2}, {'Var',1,inf}
%
%                      Caution: 2 means observation 2 of the IRF, and as
%                               the IRF start at period 0, this means that
%                               observation 2 is period 1.
%
% - 'normalizeTo'    : 'draws' or 'mean'. 'draws' normalize each draw of
%                      irfs, while 'mean' normalize the mean and scale
%                      percentiles/other draws accordingly. Default is 
%                      'draws'.
%
%                      Caution: Setting this to 'mean' will not work for
%                               reported variables that is not measured
%                               as % deviation from stead-state/mean.
%
% - 'newReplic'      : When out of parameter draws, this factor decides how
%                      many new draws are going to be made. Default is 0.1.
%                      I.e. 1/10 of the replic input. 
%
% - 'parallel'       : Give true if you want to do the irfs in parallel. 
%                      This option will parallelize over models. Default 
%                      is false.
%
% - 'parallelL'      : Give true if you want to do the irfs in parallel. 
%                      This option will parallelize over parameter 
%                      simulations. Only an option if numel(obj) == 1. 
%                      Default is false.
%
% - 'pause'          : true or false, Enable or disable pause option
%                      when calculating the irfs. Default is true.
%
% - 'perc'           : Error band percentiles. As a 1 x numErrorBand 
%                      double. E.g. [0.3,0.5,0.7,0.9]. If empty (default) 
%                      all the simulation will be returned. (The graph 
%                      will give percentiles specified by the 'fanPerc' 
%                      input (0.68).)
%
% - 'periods'        : Number of periods of the impulse responses.
% 
% - 'plotSS'         : Set to true to plot the steady-state in the IRF 
%                      graphs. Default is false. Only for nb_dsge objects.
%
% - 'plotDevInitSS'  : Set to true to plot the IRFs as deviation from the
%                      initial steady state. Only an option if 'plotSS'
%                      is set to true. Only for nb_dsge objects.
%
% - 'replic'         : The number of parameter draws.
%
%                      Caution: 'perc' must be used to produce error bands!
%
%                      Caution: Will not have anything to say for the
%                               method 'identDraws'. See the option 
%                               'draws' of the method 
%                               nb_var.set_identification for more.
% 
% - 'settings'       : Extra graphs settings given to nb_plots 
%                      function. Must be a cell.
%
% - 'shocks'         : Which shocks to create impulse responses of.
%                      Default is the residuals defined by the first model.
%                 
%                      For Markov switching or break point models it may 
%                      be wanted to only run a IRF when switching the
%                      state. To do so set this option to {'states'}.
%                      You should also set 'startingValues' to 
%                      'steadystate(r)', where r is the regime you start  
%                      in. For a Markov switching model also set 
%                      'startingProb' to the same r. This is only an    
%                      option if 'type' is set to 'irf'.
%     
% - 'sign'           : Sign of the impulse. Either 1 or -1. Can also be
%                      a vector of the same size as 'shocks' input.
%  
% - 'stabilityTest'  : Give true if you want to discard the draws 
%                      that give rise to an unstable model. Default
%                      is false.
%
% - 'startingProb'   : Either a double or a char (Only for Markov-switching 
%                      models):
%
%                      > scalar        : Select the the regime to take the  
%                                        initial transition probabilities 
%                                        from.
%
%                      > double        : A draws x nRegime or a 1 x  
%                                        nRegime double. draws refer to  
%                                        the number set by the 'draws' 
%                                        input. 
%
%                      > 'ergodic'     : Start from the ergodic transition 
%                                        probabilities. Default for 'irf'.
%
%                      > 'random'      : Randomize the starting values
%                                        using the simulated starting
%                                        points. Default for 'girf'.
%
% - 'startingValues' : Either a double or a char:
%
%      > double        : A nVar x 1 double. 
%
%      > 'steadystate' : Start from the steady state. If you are dealing 
%                        with a MS-model or a break-point model you can 
%                        indicate the regime by 'steadystate(regime)'. E.g.  
%                        to start in regime 1 give; 'steadystate(1)'. For 
%                        MS - models the default is the ergodic mean 
%                        (default as long as 'girf' is not selected as  
%                        'type'), while for break-point models it is to 
%                        start from the first regime.
%
%      > 'zero'        : Start from zero on all variables.
%
%      > 'random'      : Randomize the starting values using the simulated
%                        starting points. Default when 'type' set to 
%                        'girf'.
%
% - 'states'         : Either an integer with the states to produce irf in,  
%                      or a double with the states to condition on. Must
%                      have size periods x 1 in the last case. Applies to
%                      both MS - models and break-point models.
%
% - 'type'           : 'girf' or 'irf'. (If empty 'irf' will be used)
%
%                 > 'girf' : Generlized impulse response function
%                            calculated as the mean difference between 
%                            shocking the model with a one period shock 
%                            (1 std) and no shock at all. Use the 'draws'
%                            input to set the number of simulations to use
%                            to base the calculation on. This type of 
%                            irfs must be used for non-linear models.
%
%                 > 'irf'  : Standard irf for linear models. Calculated by
%                            shocking the model with a one period shock 
%                            (1 std).
%
% - 'variables'      : The variables to create impulse responses of.
%                      Default is the dependent variables defined by the 
%                      first model.
%
%                      Caution: The variables reported by the reporting
%                               property may also be asked for here!
%
% - 'variablesLevel' : As a cellstr. The variables to transform to level
%                      using the method specified by 'levelMethod'.
%
% Output:
%
% - irfs      : The (central) impulse response function stored in a  
%               structure of nb_ts object. Each field stores the the  
%               impulse responses of each shock. Where the variables  
%               of the nb_ts object is the impulse responses of the  
%               wanted endogenous variables.
%         
%               I.e. the impuls responses to the shock 'E_X_NW' is 
%               stored in irfs.('E_X_NW'). Which will then be a nb_ts 
%               object of all the wanted variables.
%         
%               Caution: If more nb_model_generic objects are given, the
%                        responses from each model are saved as 
%                        different datasests (pages) of the nb_ts object. 
%
%               Caution: Each nb_model_generic object can have different
%                        variables and shocks.
%
% - irfsBands : A struct with the shocks as fieldnames. Each field store
%               a nb_ts object with the error bands of all variables. The
%               pages of the nb_ts object is the percentiles (from lower
%               to upper)/simulations. 
%
%               Caution: Only the first model will get error bands!
% 
% - plotter   : An object of class nb_graph_ts. 
%
%               > 'compareShocks' set to false (default)
%                   Use the graphSubPlots method or the  
%                   nb_graphSubPlotGUI class to produce the graphs.
%
%               > 'compareShocks' set to true
%                   Use the graphSubPlots method or the 
%                   nb_graphSubPlotGUI class to produce the graphs.
%
% - obj       : If the process has been paused, some temporary output will
%               be stored in the object, and if you want to continue at a
%               later stage you can take up from this point using this
%               returned output. If not paused this output is empty.
%
% See also:
% nb_model_generic.parameterDraws, nb_irfEngine, nb_irfEngine.irfPoint
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj   = obj(:);
    names = getModelNames(obj);
    if any(~issolved(obj))
        error([mfilename ':: The models ' toString(names(~issolved(obj))) ' are not solved.'])
    end

    % Parse the arguments
    %--------------------------------------------------------------
    methods      = {'bootstrap','wildBootstrap','blockBootstrap',...
                    'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
                    'posterior','identDraws',''}; 
    levelMethods = {'cumulative product','cumulative sum','cumulative product (log)','cumulative sum (exponential)',...
                    'cumulative product (%)','cumulative sum (%)','cumulative product (log) (%)',...
                    'cumulative sum (exponential) (%)','4 period growth (log approx)',''};
    normalizeTo  = {'draws','mean'};            
    default = {'addSS',             true,       {@nb_isScalarLogical,'||',@nb_isScalarNumber};...
               'plotSS',            false,      {@nb_isScalarLogical,'||',@nb_isScalarNumber};...
               'plotDevInitSS',     false,      {@nb_isScalarLogical,'||',@nb_isScalarNumber};...
               'parallel',          false,      {@nb_isScalarLogical,'||',@nb_isScalarNumber};...
               'parallelL',         false,      {@nb_isScalarLogical,'||',@nb_isScalarNumber};...
               'cores',             [],         {@nb_isScalarInteger,'&&',{@gt,0},'||',@isempty};...
               'replic',            1,          {@nb_isScalarInteger,'&&',{@gt,0}};...
               'draws',             1000,       {@nb_isScalarInteger,'&&',{@gt,0}};...
               'fanPerc',           0.68,       @isnumeric;... 
               'irfCompare',        [],         @isstruct;...
               'newReplic',         0.1,        {@nb_isScalarNumber,'&&',{@gt,0}};...
               'method',            '',         {@ischar,'&&',{@nb_ismemberi,methods}};...
               'type',              'irf',      {@ischar,'&&',{@nb_ismemberi,{'girf','irf'}}};...
               'sign',              1,          {{@ismember,[1,-1]}};...
               'factor',            {},         {@iscell,'||',@isempty};...
               'startingValues',    '',         {@ischar,'||',@isnumeric};...
               'startingProb',      '',         {@ischar,'||',@isnumeric};...
               'stabilityTest',     false,      @islogical;...
               'states',            [],         {@isnumeric,'||',@isempty};...
               'periods',           40,         {@nb_isScalarInteger,'&&',{@gt,0}};...
               'shocks',            {},         {@iscellstr,'||',@isempty};...
               'variables',         '',         {@iscellstr,'||',@isempty};...
               'normalize',         {}          {@iscell,'||',@isempty};...
               'normalizeTo',       'draws'     {{@nb_ismemberi,normalizeTo}};...
               'variablesLevel',    {},         {@iscellstr,'||',@isempty};...
               'perc',              [],         {@isnumeric,'||',@isempty};...
               'levelMethod',       '',         {{@nb_ismemberi,levelMethods}};...
               'pause',             true,       {@nb_isScalarLogical,'||',{@ismember,[0,1]}};...
               'continue',          false,      {@nb_isScalarLogical,'||',{@ismember,[0,1]}};...
               'foundReplic',       [],         {@isstruct,'||',@isempty};...
               'settings',          {},         {@iscell,'||',@isempty};...
               'compare',           false,      {{@ismember,[true,false]}};...
               'compareShocks',     false,      {{@ismember,[true,false]}};...
               'compareVars',       false,      {{@ismember,[true,false]}}};
           
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if inputs.compareShocks || inputs.compareVars
        if ~isscalar(obj)
            error([mfilename ':: The obj input must be a scalar nb_model_generic object when either ''compareShocks'' or ''compareVars'' are set to true.'])
        end
        if inputs.compareShocks && inputs.compareVars
            error([mfilename ':: You cannot seth both ''compareShocks'' or ''compareVars'' to true.'])
        end
    end
    
    if isempty(inputs.shocks)
        inputs.shocks = obj(1).solution.res;
        if isNB(obj(1)) || isRise(obj(1))
            if iscell(obj(1).solution.C)
                sig = sum(obj(1).solution.C{1}(:,:,end),1) == 0;
            else
                sig = sum(obj(1).solution.C(:,:,end),1) == 0;
            end
        else
            sig = diag(obj(1).solution.vcv(:,:,end)) == 0;
        end
        inputs.shocks = inputs.shocks(~sig);
    end
    
    if isempty(inputs.variables)
        inputs.variables = obj(1).dependent.name; 
        if isa(obj(1),'nb_var')
            inputs.variables = [inputs.variables,obj(1).block_exogenous.name];
        end
        if isa(obj(1),'nb_factor_model_generic')
            inputs.variables = [inputs.variables,obj(1).estOptions.factors];
        end
    else
        
        % Separate out variables and expressions
        if isscalar(obj)
            tested = obj.dependent.name;
            if ~isempty(obj.reporting)
                tested = [tested,obj.reporting(:,1)'];
            end
        else
            tested = cell(1,numel(obj));
            for ii = 1:numel(obj)
                tested{ii} = obj(ii).dependent.name;
                if ~isempty(obj(ii).reporting)
                    tested{ii} = [tested{ii},obj(ii).reporting(:,1)'];
                end
            end
            tested = nb_nestedCell2Cell(tested);
        end
        found       = ismember(inputs.variables,tested);
        expressions = inputs.variables(~found);
        
        if ~isempty(expressions)
            for ii = 1:numel(obj)
                added = [expressions',expressions',cell(size(expressions,2),1)];
                rep   = obj(ii).reporting;
                if isempty(rep)
                    rep = added;
                else
                    rep = [rep;added]; %#ok<AGROW>
                end
                obj(ii) = set(obj(ii),'reporting',rep);  
            end
        end
        
    end
    inputs.variables = unique(inputs.variables,'stable');
    
    if isempty(inputs.states)
        if isa(obj(1),'nb_dsge')
            if isNB(obj(1))
                inputs.states = ones(inputs.periods,1);
            else
                inputs.states = nan(inputs.periods,1);
            end
        else
            inputs.states = nan(inputs.periods,1);
        end
    else
        if isscalar(inputs.states)
            inputs.states = inputs.states(ones(1,inputs.periods),:);
        elseif size(inputs.states,1) ~= inputs.periods
            error([mfilename ':: The states input must be a periods x 1 double.'])
        end
    end
    
    % Split object if the compare option is used
    if isscalar(obj) 
        if isa(obj,'nb_dsge')
            if or(isNB(obj),isRise(obj))
                if inputs.compare
                    obj = split(obj); 
                end
            else
                if inputs.compare
                    error([mfilename ':: The compare option can only be set to true when dealing with a scalar nb_dsge model '...
                                     'solved with NB Toolbox or RISE.'])
                end
            end
        else
            if inputs.compare
                error([mfilename ':: The compare option can only be set to true when dealing with a scalar nb_dsge model.'])
            end
        end
    else
        if inputs.compare
            error([mfilename ':: The compare option can only be set to true when dealing with a scalar nb_dsge model.'])
        end
    end
        
    % Get the inputs for each model (used by waitbar)
    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 1
        inputs.parallel = false;
    else
        inputs.parallelL = false;
    end
    if ~isempty(inputs.foundReplic)
        if nobj ~= 1
            error([mfilename ':: The ''foundReplic'' options only work for scalar nb_model_generic object.'])
        end
    end
    inputs.irfData = [];
    inputs.nObj    = [];
    inputs.index   = [];
    inputs.y0      = [];
    inputs.PAI0    = [];
    inputsW        = inputs(:,ones(1,nobj));
    if inputs.continue
        for ii = 1:nobj
            try
                fields = fieldnames(obj(ii).tempOutput.inputs);
                for ff = 1:length(fields)
                    inputsW(ii).(fields{ff}) = obj(ii).tempOutput.inputs.(fields{ff});
                end
            catch %#ok<CTCH>
                error([mfilename ':: No output from an earlier paused call to this method is stored for the model ' names{ii} '!'])
            end
            if isempty(inputsW(ii).irfData)
                error([mfilename ':: No output from an earlier paused call to this method is stored for the model ' names{ii} '!'])
            end
            inputsW(ii).continue = true;
        end
        inputs = inputsW(1);
    else
        index               = num2cell(1:nobj);
        [inputsW(:).nObj]   = deal(nobj);
        [inputsW(:).index]  = index{:};
        
        % Interpret the startingValue input
        for ii = 1:nobj
           [inputsW(ii).y0,inputsW(ii).PAI0] = getStartingValues(obj(ii),inputs);
        end
    end
    
    for ii = 1:nobj
        inputsW(ii).reporting = obj(ii).reporting;
        if isa(obj(ii),'nb_dsge')
            if isNB(obj(ii))
                if ~isestimated(obj(ii))
                    estOpt  = createEstOptionsStruct(obj(ii));
                    obj(ii) = setEstOptions(obj(ii),estOpt);
                else
                    if inputs.replic > 1
                        % This should be prevented in the future by correcting
                        % nb_dsge.solveNormal!
                        obj(ii).estOptions.parser.object = obj(ii);
                    end
                end
            end
            obj(ii).estOptions.class = 'nb_dsge';
        end
    end
    
    % Produce the irfs
    %--------------------------------------------------------------
    irfData   = cell(1,nobj);
    paused    = cell(1,nobj);
    solutions = {obj.solution};
    opt       = {obj.estOptions};
    res       = {obj.results};
    if inputs(1).parallel && nobj > 1
        if inputs(1).parallelL
            error([mfilename ':: Cannot do parellel at the lower level as well as over objects!'])
        end
        
        ret = nb_openPool(inputs(1).cores);
        
        % Build a WorkerObjWrapper object to write to a worker specific
        % file
        w = nb_funcToWrite('forecast_worker','gui');
        for ii = 1:nobj
           inputsW(ii).waitbar = w; 
        end
        
        parfor ii = 1:nobj
            [irfData{ii},paused{ii}] = nb_irfEngine(solutions{ii},opt{ii}(end),res{ii},inputsW(ii));
            fprintf(w.Value,['IRF of Model '  int2str(ii) ' of ' int2str(nobj) ' finished.\r\n']); %#ok<PFBNS>
        end
        delete(w);
        clear w; % causes "fclose(w.Value)" to be invoked on the workers 
        nb_closePool(ret);
        
    else
        for ii = 1:nobj
            [irfData{ii},paused{ii}] = nb_irfEngine(solutions{ii},opt{ii}(end),res{ii},inputsW(ii));
        end
    end
    
    % Check the pause output
    hasBeenPaused = false;
    for ii = 1:nobj
        if paused{ii}
            inputsW(ii).irfData       = irfData{ii}(:,:,:,1:end-1); % Remove median
            obj(ii).tempOutput.inputs = inputsW(ii);
            hasBeenPaused             = true;
        else
            obj(ii).tempOutput = struct;
        end
    end
    
    % Merge output
    %--------------------------------------------------------------
    vars           = inputs.variables;
    variablesLevel = inputs.variablesLevel;
    if isempty(variablesLevel)
        allVars = vars;
    else
        allVars = [vars,strcat('level_',variablesLevel)];
    end
    if hasBeenPaused
        irfData          = cleanIrfData(inputsW,irfData);
        [irfs,irfsBands] = mergeOutput(irfData,inputs.shocks,allVars,inputs.perc,inputs.factor);
    else
        [irfs,irfsBands] = mergeOutput(irfData,inputs.shocks,allVars,inputs.perc,inputs.factor);
    end
    
    % Merge with IRFs to compare to
    if isstruct(inputs.irfCompare)
        
        % Merge irfs into one struct
        fields     = fieldnames(inputs.irfCompare);
        fieldsThis = fieldnames(irfs);
        test       = ismember(fieldsThis,fields);
        irfsMerged = struct();
        vars       = irfs.(fieldsThis{1}).variables;
        numPages   = inputs.irfCompare.(fields{1}).numberOfDatasets;
        for ii = 1:length(fieldsThis)
            if test(ii)
                new = inputs.irfCompare.(fieldsThis{ii});
            else
                new = nb_ts(nan(inputs.periods,length(vars),numPages),'',0,vars);
            end
            irfsMerged.(fieldsThis{ii}) = addPages(irfs.(fieldsThis{ii}), new);
        end
        names = [names;nb_appendIndexes('Compare2',1:numPages)];
        irfs  = irfsMerged;
        
    end
    
    % Plot if wanted
    %--------------------------------------------------------------
    if nargout > 2
        
        if inputs.compareShocks
            plotter = makeAllInOnePlotter(irfs,inputs,false);
        elseif inputs.compareVars
            plotter = makeAllInOnePlotter(irfs,inputs,true);
        else
            plotter = makeStandardPlotter(obj,irfs,irfsBands,names,inputs);
        end
        if isscalar(obj)
            set(plotter,'parameters',getParameters(obj,'struct'));
        end
        
    end
    
    if ~hasBeenPaused
        obj = [];
    end

end

%==========================================================================
% SUB
%==========================================================================
function [y0,PAI0] = getStartingValues(obj,inputs)

    PAI0 = [];
    sv   = inputs.startingValues;
    girf = false;
    if strcmpi(inputs.type,'girf')
        if isempty(sv)
            sv   = 'random';
            girf = true;
        end
        if isempty(inputs.startingProb)
            inputs.startingProb = 'random';
        end
    else
        if isempty(sv)
            sv = 'zero';
            if isa(obj,'nb_dsge')
                if (isNB(obj) || isRise(obj)) && iscell(obj.solution.ss)
                    sv = 'steady_state';
                end
            end
        end
        if isempty(inputs.startingProb)
            inputs.startingProb = 'ergodic';
        end
    end
    
    if isfield(obj.solution,'A')
        test = obj.solution.A;
    else
        test = obj.solution.ss;
    end
    if iscell(test)
        test = test{1};
    end
    N = size(test,1);
    
    if isnumeric(sv)  
        if size(sv,1) ~= N || size(sv,2) ~= 1
            error([mfilename ':: The startingValues input must be set to a ' int2str(N) 'x1 double. '...
                '(Is ' int2str(size(sv,1)) 'x' int2str(size(sv,2)) ')'])
        end
        if isa(obj,'nb_pit_model_generic')
            dist = obj.results.densities;
            if isa(obj,'nb_pitvar')
                dist = repmat(dist,[1,obj.estOptions.nLags + 1]);
            end
            for ii = 1:size(sv,1)
                sv(ii) = cdf(dist(1,ii),sv(ii));
                sv(ii) = nb_distribution.normal_icdf(sv(ii),0,1);
            end
            
        end
        if iscell(obj.solution.A)
            PAI0 = getStartingProb(obj,inputs,[],girf);
        end
        y0 = sv;
    else
    
        % Check which steady state to begin from (MS-models)
        out = regexp(sv,'(','split');
        if size(out,2) == 2
            sv    = out{1};
            ssInd = out{2};
            ssInd = round(str2double(ssInd(1:end-1)));
        else
            ssInd = [];
        end
        
        switch lower(sv)

            case {'zero','zeros'}

                if girf
                    y0 = zeros(N,inputs.draws);
                else
                    y0 = zeros(N,1);
                end
                if nb_isModelMarkovSwitching(obj.solution)
                    PAI0 = getStartingProb(obj,inputs,[],girf);
                end
                
            case {'steady_state','steadystate'}

                model = obj.solution;
                if isfield(model,'ss')
                    if iscell(model.ss)
                        if isempty(ssInd) || isnan(ssInd)
                            if nb_isModelMarkovSwitching(model)
                                ss = ms.integrateOverRegime(Q,model.ss);
                            else
                                ss = model.ss{1};
                            end
                        else
                            try
                                ss = model.ss{ssInd};
                            catch %#ok<CTCH>
                                error([mfilename ':: The model ' obj.name ' has no regime ' int2str(ssInd)])
                            end
                        end
                    else
                        ss = model.ss;
                    end    
                else
                    ss = theoreticalMoments(obj,'output','double','vars','full');
                end
                if girf
                    y0 = ss(:,ones(1,inputs.draws));
                else
                    y0 = ss;
                end
                if issparse(y0)
                    y0 = full(y0);
                end
                if nb_isModelMarkovSwitching(obj.solution)
                    PAI0 = getStartingProb(obj,inputs,[],girf);
                end
                
            case 'random'

                if nb_isModelMarkovSwitching(obj.solution)
                    sim = simulate(obj,30,'regimeDraws',inputs.draws/2,...
                                          'draws',2,...
                                          'startingProb',  'ergodic',...
                                          'startingValues','steadystate');
                else
                    sim = simulate(obj,30,'draws',         inputs.draws,...
                                          'startingValues','steadystate');
                end
                
                % Get the starting value sof the endogenous
                fields   = fieldnames(sim);
                simObj   = sim.(fields{1}); 
                vars     = simObj.variables;
                sim      = double(simObj);
                endo     = obj.solution.endo;
                [~,indE] = ismember(endo,vars);
                y0       = permute(sim(end,indE,:),[2,3,1]);
                
                % Get the starting values of the transition probabilities
                if nb_isModelMarkovSwitching(obj.solution)
                    PAI0 = getStartingProb(obj,inputs,simObj,girf);
                end
                
            otherwise
                error([mfilename ':: Unsupported value given to the startingValue input.'])
                
        end
        
    end
        
end

%==========================================================================
function PAI0 = getStartingProb(obj,inputs,simObj,girf)

    sp = inputs.startingProb;
    Q  = obj.solution.Q;
    if isscalar(sp) && isnumeric(sp)
        
        PAI0 = Q(sp,:).';
        if girf
            PAI0 = sp(:,ones(1,inputs.draws));
        end
        
    elseif isnumeric(sp)
        
        if size(sp,1) ~= size(Q,1)
            error([mfilename ':: Dimension 1 of the startingProb input must be equal to the number of regimes (' int2str(size(Q,1)) ').'])
        end
        if girf
            if size(sp,2) == 1 
                PAI0 = sp(:,ones(1,inputs.draws));
            elseif size(sp,2) == inputs.draws
                PAI0 = sp;
            else
                error([mfilename ':: Dimension 2 of the startingProb must either be 1 or ' int2str(inputs.draws)])
            end
        else
            if size(sp,2) == 1 
                PAI0 = sp;
            else
                error([mfilename ':: Dimension 2 of the startingProb must either be 1'])
            end
        end
            
    else 
        
        switch lower(sp)

            case 'ergodic'

                [PAI0,retcode] = initial_markov_distribution(Q,true);
                if retcode
                    error([mfilename ':: Could not calculate the ergodic transition probability.'])
                end
                if girf 
                    PAI0 = PAI0(:,ones(1,inputs.draws));
                end
                
            case 'random'

                if isempty(simObj)
                    sim    = simulate(obj,100,'regimeDraws',   inputs.draws,...
                                              'startingProb',  'ergodic',...
                                              'startingValues','steadystate');
                    fields = fieldnames(sim);
                    simObj = sim.(fields{1});
                end
                
                vars     = simObj.variables;
                sim      = double(simObj);
                [~,indS] = find(strcmpi('states',vars));
                st       = permute(sim(end,indS,:),[2,3,1]);
                PAI0     = nan(size(Q,1),inputs.draws);
                for ii = 1:size(st,2)
                    PAI0(:,ii) = Q(st(ii),:).';
                end
                if ~girf 
                    PAI0 = PAI0(:,1);
                end
                
            otherwise
                error([mfilename ':: Unsupported startingProb input; ' sp])
                
        end
        
    end
    
end

%==========================================================================
function [irfs,irfsBands] = mergeOutput(irfsC,shocks,vars,perc,factor)
% Merge output and reorder things

    % Get the actual lower and upper percentiles
    perc = nb_interpretPerc(perc,false);

    % Set up stuff
    irfs        = struct();
    nModels     = length(irfsC);
    irfData     = [irfsC{:}];
    irfData     = permute(irfData,[1,3,4,2]);
    nPeriods    = size(irfData,1);
    nPerc       = size(irfData,3) - 1;
    nVars       = length(vars);
    nShocks     = length(shocks);
    irfData     = reshape(irfData,[nPeriods,nShocks,nPerc+1,nVars,nModels]);
    irfData     = permute(irfData,[1,4,2,3,5]);
    
    % Interpret the factor input
    %-----------------------------
    factorValue = ones(nPeriods,nVars,nShocks,nModels);
    if ~isempty(factor)
        factorValue = applyFactor(factorValue,factor,vars);
    end
    
    % Get the mean
    %---------------------------------------------
    for ii = 1:nShocks
        
        irfDataTemp       = permute(irfData(:,:,ii,end,:),[1,2,5,4,3]);
        factorValueShock  = permute(factorValue(:,:,ii,:),[1,2,4,3]);
        irfDataTemp       = irfDataTemp.*factorValueShock;
        if nPerc > 0
            name = 'Median';
        else
            name = 'Point';
        end
        irfs.(shocks{ii}) = nb_ts(irfDataTemp,name,'0',vars);
        
    end
    
    % Get the error band from only the first model
    %----------------------------------------------
    irfsBands = [];
    if nPerc > 0
        
        irfsBands = struct();
        for ii = 1:nShocks
    
           irfDataTemp       = permute(irfData(:,:,ii,1:end-1,1),[1,2,4,3,5]);
           factorValueShock  = factorValue(:,:,ii,1);
           if ~isempty(factor)
               irfDataTemp = irfDataTemp.*repmat(factorValueShock,[1,1,nPerc]);
           end
           data = nb_ts(irfDataTemp,'Simulation','0',vars);
           if ~isempty(perc)
               data.dataNames = cellstr(int2str(perc(:)));
           end
           irfsBands.(shocks{ii}) = data;
        
        end
        
    end
    
end

%==========================================================================
function factorValue = applyFactor(factorValue,factor,vars)

    % Do this to be robust to old versions! 
    factor = nb_nestedCell2Cell(factor);
    if rem(length(factor),2) ~= 0
       error([mfilename ':: The factor input must be given a cellstr with pairs of a variable ',...
                        'name and the factor the given variable are to be multiplied with; {''Var1'',2,''Var2'',3}']) 
    end

    for kk = 1:2:size(factor,2)

        factorVar = factor{kk+1};
        if ~isnumeric(factorVar)
            continue
        end

        varName = factor{kk};
        if isempty(varName) 
            continue
        end
        if iscellstr(varName)
            indVar = ismember(vars,varName);
        elseif strncmp(varName,'*',1)
            indVar = ~cellfun(@(x)isempty(x),strfind(vars,varName(2:end)));
        elseif ~ischar(varName)
            continue
        else
            indVar = strcmp(varName,vars);
        end
        factorValue(:,indVar,:,:) = factorValue(:,indVar,:,:)*factorVar;
        
    end
        
end

%==========================================================================
function irfDataD = cleanIrfData(inputs,irfDataD)

    for ii = 1:length(irfDataD)

        % Remove the unfinished simulations
        irfDataT = irfDataD{ii};
        keep     = ~isnan(irfDataT(1,1,1,:));
        keep     = permute(keep,[4,1,2,3]);
        irfDataT = irfDataT(:,:,:,keep);

        % Get the actual lower and upper percentiles
        perc  = nb_interpretPerc(inputs(ii).perc,false);
        nPerc = length(perc);

        % Get the percentiles and median
        %...............................
        nVars   = length(inputs(ii).variables) + length(inputs(ii).variablesLevel);
        nShocks = length(inputs(ii).shocks);
        irfData = nan(inputs(ii).periods+1,nVars,nShocks,nPerc+1);
        for jj = 1:nPerc
            irfData(:,:,:,jj) = prctile(irfDataT,perc(jj),4);
        end
        irfData(:,:,:,end) = median(irfDataT,4);
        irfDataD{ii}       = irfData;
        
    end

end

%==========================================================================
function plotter = makeStandardPlotter(obj,irfs,irfsBands,names,inputs)

    if isa(obj,'nb_dsge')
        if inputs.plotSS
            [irfs,names,inputs] = getSteadyStateFromModels(irfs,obj,names,inputs);
        end
    end

    settings = [{'axesFast',         false,...
                 'spacing',          5,...
                 'xTickStart',       '5',...
                 'subPlotSize',      [3,3],...
                 'figureTitle',      1,...
                 'legends',          names,...
                 'variablesToPlot',  inputs.variables},...
                 inputs.settings];
    if ~isempty(irfsBands)

        fields  = fieldnames(irfsBands);
        irfData = nb_ts();
        for ii = 1:length(fields)

            % We append the variables names with the fieldname to make
            % it possible to merge the dataset with the others
            temp           = irfsBands.(fields{ii});
            temp.variables = strcat(temp.variables,'_',fields{ii});
            irfData        = irfData.merge(temp);

        end
        irfData.dataNames = temp.dataNames;
        if isempty(inputs.perc)
            fanPerc = inputs.fanPerc;
        else
            fanPerc = inputs.perc;
        end
        settings = [settings,{'fanDatasets',irfData,'fanPercentiles',fanPerc,'fanColor','grey'}];

    end
    plotter = nb_plots(irfs,settings{:}); 

end

%==========================================================================
function plotter = makeAllInOnePlotter(irfs,inputs,perm)

    % Collect IRFs of different shocks
    fields            = fieldnames(irfs);
    newIrfs           = irfs.(fields{1});
    newIrfs.dataNames = fields(1);
    
    for ii = 2:length(fields)
        tempIrfs           = irfs.(fields{ii});
        tempIrfs.dataNames = fields(ii);
        newIrfs            = addPages(newIrfs,tempIrfs);
    end
    
    if perm
        newIrfs = permute(newIrfs); %#ok<LTARG>
        vars    = inputs.shocks;
    else
        vars = inputs.variables;
    end
    
    % Make plotter object
    settings = [{'axesFast',       true,...
                 'spacing',        5,...
                 'xTickStart',     '5',...
                 'subPlotSize',    [3,3],...
                 'variablesToPlot',vars(:)'},...
                inputs.settings];
    plotter = nb_graph_ts(newIrfs);
    plotter.set(settings);
    
end

%==========================================================================
function [irfs,allNames,inputs] = getSteadyStateFromModels(irfs,obj,names,inputs)

    nobj      = length(obj);
    fields    = fieldnames(irfs);
    vars      = irfs.(fields{1}).variables;

    % Add gaps as deviation from inital steady-state
    ss          = nan(inputs.periods+1,length(vars),nobj);
    ss(1,:,:)   = double(window(irfs.(fields{1}),'0','0')); % The IRFs start from the initial SS!
    for mm = 1:length(fields) 
        irfData    = double(irfs.(fields{mm}));
        irfInitGap = real(bsxfun(@minus, log(irfData), log(ss(1,:,:))));
        indGaps    = all(~isfinite(irfInitGap),1);
        ssInitGap  = nb_ts();
        for oo = 1:nobj
            varsInitG     = strcat(vars(~indGaps(:,:,oo)),'_GAP_INIT');
            irfInitGapOne = irfInitGap(:,~indGaps(:,:,oo),oo);
            if ~isempty(inputs.factor)
                factorValue   = ones(size(irfInitGapOne));
                factorValue   = applyFactor(factorValue,inputs.factor,varsInitG);
                irfInitGapOne = irfInitGapOne.*factorValue;
            end
            ssInitGapOne = nb_ts(irfInitGapOne,'','0',varsInitG);
            ssInitGap    = addPages(ssInitGap,ssInitGapOne);
        end
        irfs.(fields{mm}) = merge(irfs.(fields{mm}),ssInitGap);
    end
    
    % Get the steady-state (changes) of all the models.
    vars      = irfs.(fields{1}).variables;
    ss        = nan(inputs.periods+1,length(vars),nobj);
    ss(1,:,:) = double(window(irfs.(fields{1}),'0','0')); % The IRFs start from the initial SS!
    indInit   = ismember(vars,ssInitGap.variables);
    varsLevel = strrep(vars(indInit),'_GAP_INIT','');
    if ~isempty(varsLevel)
        for mm = 1:nobj 

            exprSS    = vars(~indInit);
            exprL     = varsLevel;
            reporting = obj(mm).reporting;
            if ~isempty(reporting)
                [test,loc]   = ismember(exprSS,reporting(:,1));
                loc          = loc(test);
                exprSS(test) = reporting(loc,2);
                [test,loc]   = ismember(exprL,reporting(:,1));
                loc          = loc(test);
                exprL(test)  = reporting(loc,2);
            end

            ssRegimes             = getSteadyState(obj(mm),exprSS,'double')';
            ssTemp                = getSteadyState(obj(mm),exprL,'double')';
            ssTemp                = ssTemp(inputs.states,:);
            indLevel              = ismember(vars,varsLevel);
            ss(2:end,indInit,mm)  = real(bsxfun(@minus, log(ssTemp), log(ss(1,indLevel,mm))));
            if ~isempty(inputs.factor)
                ssTempFact       = ss(:,indInit,mm);
                factorValue      = ones(size(ssTempFact));
                factorValue      = applyFactor(factorValue,inputs.factor,varsInitG);
                ss(:,indInit,mm) = ssTempFact.*factorValue;
            end
            ss(2:end,~indInit,mm) = ssRegimes(inputs.states,:);
            indGaps               = all(ss(2:end,:,mm) == 0,1);
            ss(:,indGaps,mm)      = nan;

        end
    end
    ssNames = strcat(names,'(SS)');
    ssIRF   = nb_ts(ss,ssNames,'0',vars);
    
    % Add the steady-state (changes) to separate pages the IRFs of all
    % innovations
    for ii = 1:length(fields)
        irfs.(fields{ii}).dataNames = names;
        irfs.(fields{ii})           = addPages(irfs.(fields{ii}),ssIRF);
    end
    
    if inputs.plotDevInitSS
        deletedVars = varsLevel;
    else
        deletedVars = varsInitG;
    end
    for ii = 1:length(fields)
        irfs.(fields{ii}) = deleteVariables(irfs.(fields{ii}),deletedVars);
    end
    if inputs.plotDevInitSS
        for ii = 1:length(fields)
            irfs.(fields{ii}) = renameMore(irfs.(fields{ii}),'variables',varsInitG,varsLevel);
        end
    end
    
    % Update the names
    allNames = [nb_rowVector(names),nb_rowVector(ssNames)];
    
    % Set line styles of SS to 'none'
    lineStyles          = cell(1,nobj*2);
    lineStyles(1:2:end) = allNames(nobj+1:nobj*2);
    lineStyles(2:2:end) = {'none'};
    
    % Set markers for the SS
    markers          = lineStyles;
    markers(2:2:end) = {'*'};
    
    % Assign to the graph settings
    inputs.settings = [inputs.settings,{'lineStyles',lineStyles,'markers',markers,'markerSize',1}];%'colors',colors,
    
end
