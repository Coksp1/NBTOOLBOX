function out = simulate(obj,nSteps,varargin)
% Syntax:
%
% out = simulate(obj,nSteps,varargin)
%
% Description:
%
% Make simulations from model.
%
% Caution : Will only simulate using the full sample estimate of
%           recursively estimated model.
% 
% Input:
% 
% - obj      : A vector of nb_model_generic objects. 
% 
% - nSteps   : Number of simulation steps. As a 1x1 double. Default is 100.
%
% Optional inputs:
%
% - 'burn'           : The number of periods to remove at start of the
%                      simulations. This is to randomize the starting
%                      values of the simulation. Default is 0.
%
% - 'bounds'         : A struct. Each fieldname must be the name of the
%                      variable to add bounds on. Each field must again be
%                      a struct with the following fields:
%           
%                      - 'shock' : Name of the shock to match the 
%                                  restriction on the bounds of the given
%                                  variable.
%
%                      - 'lower' : The lower bound of the selected
%                                  variable. Either a 1x1 double value
%                                  or a function handle to a probability
%                                  distribution to draw from.
%
%                      - 'upper' : The upper bound of the selected
%                                  variable. Either a 1x1 double value
%                                  or a function handle to a probability
%                                  distribution to draw from.
%
%                      Caution : The function handles must take one input.
%                                I.e. the vector of current observations
%                                of the endogneous variables, as a nVar x
%                                nSteps double matix. For the order of the
%                                variables see; obj.solution.endo. The
%                                value return by the function must be
%                                either a 1x1 double or a nSteps x 1
%                                double.
%
%                      This input can be used to use anticipated shocks
%                      to restrict variables to inside a range. E.g.
%                      effective lower bound on the interest rate.
%
% - 'condDB'         : A nb_ts object with the conditional information
%                      to base the simulation upon.
%
% - 'draws'          : Number of residual/innovation draws per parameter
%                      draw. Default is 1000. Must be larger than 0.
%
% - 'foundReplic'    : A struct with size 1 x parameterDraws. Each element
%                      must be on the same format as obj.solution. I.e.
%                      each element must be the solution of the model
%                      given a set of drawn parameters. See the 
%                      parameterDraws method of the nb_model_generic class.
%
%                      Caution: You still need to set 'parameterDraws'
%                               to the number of draws you want to do.
%
% - 'method'         : The selected method to create density forecast.
%                      Default is ''. See help on the method input of the
%                      nb_model_generic.parameterDraws method for more 
%                      this input.
%
% - 'newDraws'       : When out of parameter draws, this factor decides how
%                      many new draws are going to be made. Default is 0.1.
%                      I.e. 1/10 of the parameterDraws input. 
%
% - 'observables'    : A cellstr with the observables you want the
%                      simulation of. Only for factor models. Will be
%                      discared for all other types of models.
%
% - 'output'         : Either 'endo' (default), 'fullendo' or 'all'. This 
%                      input indicates which variables to return the 
%                      simulation of. 
%
%                      > 'endo'     : All the endogenous variables are 
%                                     returned.
%
%                      > 'fullendo' : All the endogenous variables are 
%                                     returned included the lag variables.
%
%                      > 'full'     : All the variables are returned
%                                     included the lag variables. Also  
%                                     including exogenous and shocks.
%
%                      > 'all'      : All variables are returned (but not 
%                                     the lags). Also including exogenous 
%                                     and shocks.
%    
% - 'parallel'       : Give true if you want to do the simulations in 
%                      parallel. I.e. spread models to different threads.
%                      Default is false.
%
% - 'parameterDraws' : Number of draws of the parameters. When set to 1
%                      it will discard parameter uncertainty. Default is 1.
%
% - 'regime'         : Select the regime you want to simulate. If empty
%                      the simulation will switch between regimes. Only
%                      an option for Markov switching models.
%
% - 'regimeDraws'    : Number of drawn regime paths when doing simulations.
%                      This will have no effect if the states input is 
%                      providing the full path of regimes. Default is 1.
%
% - 'seed'           : Set simulation seed. Default is 2.0719e+05.
%
% - 'startDate'      : Give the start date of the simulation. If not
%                      provided the output will be a nb_data object 
%                      without a spesific start date (default). If 
%                      provided the output will be an object of class 
%                      nb_ts.
%
%                      Caution : If dealing with break-points or exogenous
%                                time-varying parameters this input must be
%                                provided.
%
% - 'startingValues' : Either a double or a char:
%
%                      > double        : A 1 x nVar double.
%
%                      > 'mean'        : Start from the mean of the data
%                                        observations. Default for all
%                                        model except nb_dsge models. 
%
%                      > 'steadystate' : Start from the steady state. For 
%                                        now only an option for nb_dsge
%                                        models. If you are dealing with a
%                                        MS-model you can indicate the
%                                        state by 'steadystate(state)'.
%                                        E.g. to start in state 1 give;
%                                        'steadystate(1)'. Default for
%                                        nb_dsge models.
%
%                      > 'zero'        : Start from zero on all variables
%                                        (Except for the deterministic 
%                                        exogenous variables)
%
% - 'stabilityTest'  : Give true if you want to discard the parameter draws 
%                      that give rise to an unstable model. Default
%                      is false.
%
% - 'startingProb'   : Either a double or a char:
%
%                      > double        : A nPeriods x nRegime or a 1 x  
%                                        nRegime double. nPeriods refer to  
%                                        the number of recursive periods to 
%                                        forecast. 
%
%                      > 'ergodic'     : Start from the ergodic transition 
%                                        probabilities. Default.
%
% Output:
% 
% - out : A struct with the simulated variables from each model as 
%         seperate fields. Each field consist of a nSteps x nVar x 
%         parameterDraws*draws*regimeDraws nb_data (or nb_ts if the
%         'startDate' input is used) object.
%
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        nSteps = 100;
    end

    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior',''};       
    default = {'bounds',            [],         {@isempty,'||',@isstruct};...
               'burn',              [],         {@nb_isScalarInteger,'||',@isempty};...
               'condDB',            nb_ts,      {{@isa,'nb_ts'},'||',@isempty};...
               'draws',             1000,       {@nb_isScalarInteger,'&&',{@gt,0}};...
               'foundReplic',       [],         {@isstruct,'||',@isempty};...
               'method',            '',         {@ischar,'&&',{@nb_ismemberi,methods}};...
               'newDraws',          0.1,        {@nb_isScalarNumber,'&&',{@gt,0}};...
               'observables',       {},         {@iscellstr,'||',@isempty};...
               'output',            'endo',     {@ischar,'&&',{@nb_ismemberi,{'endo','full','fullendo','all',''}}};...
               'parallel',          false,      {@islogical,'||',@isnumeric};...
               'parameterDraws',    1,          {@nb_isScalarInteger,'&&',{@gt,0}};...
               'regimeDraws',       1,          {@nb_isScalarInteger,'&&',{@gt,0}};...
               'seed',              2.0719e+05, @nb_isScalarNumber;...
               'shockProps',        struct,     {@isstruct,'||',@isempty};...
               'stabilityTest',     false,      @nb_isScalarLogical;...
               'startDate',         '',         {@ischar,'||',@(x)isa(x,'nb_date')};...
               'startingValues',    '',         {@ischar,'||',@isnumeric};...
               'startingProb',      'ergodic',  {@ischar,'||',@isnumeric};...
               'states',            [],         {@nb_isScalarInteger,'||',@isempty}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % To be able to call forecast we need to add some options.
    inputs.fcstEval          = '';
    inputs.estDensity        = 'kernel';
    inputs.varOfInterest     = '';
    inputs.perc              = [];
    inputs.method            = '';
    inputs.bins              = [];
    inputs.saveToFile        = false;
    inputs.endDate           = '';
    inputs.sigma             = [];
    inputs.sigmaType         = 'none';
    inputs.estimateDensities = false;
    inputs.compareToRev      = [];
    inputs.reporting         = {};
    inputs.density           = true;
    
    removeMean = 1;
    if inputs.draws == 1 && ~isempty(inputs.condDB)
        removeMean     = 0;
        inputs.density = false;
    end
    
    % Update some properties
    if ~nb_isScalarInteger(nSteps)
        error('The nSteps input must be a scalar integer.')
    end
    if nSteps < 1
        error('The nSteps input must be grater than 0.')
    end
    
    burn = inputs.burn;
    if isempty(burn)
        burn = 0;
    else
        nSteps = nSteps + burn;
    end
    
    % Then we call
    obj      = obj(:);
    nobj     = numel(obj);
    parallel = inputs.parallel;
    names    = getModelNames(obj);
    if any(~issolved(obj))
        error(['The following models are not solved; ' toString(names(~issolved(obj)))])
    end
    if nobj == 0
        error('Cannot simulate an empty vector of nb_model_generic objects.')
    end

    % Get the inputs for each model (used by saving and waitbar)
    inputs.nObj  = nobj;
    inputs.index = 1;
    inputs       = inputs(:,ones(1,nobj));
    for ii = 1:nobj
        inputs(ii).index = ii; 
        if isa(obj,'nb_dsge')
           if ~any(strcmpi('startingValues',varargin))
               % Default for dsge models are to start form the steady
               % state
               inputs(ii).startingValues = 'steadystate';
           end
        end
    end

    % Get needed information on the models
    opt = cell(1,nobj);
    for ii = 1:nobj
        if isa(obj(ii),'nb_dsge')
            if ~isfield(obj.results,'logLikelihood') % Model is not estimated!
                % Secure that all the options are stored in the opt{ii}
                % struct passed to the nb_forecast function
                opt{ii} = createEstOptionsStruct(obj(ii));
            else
                opt{ii} = obj.estOptions;
            end
        else
            opt{ii} = obj.estOptions;
        end
    end
    sol = {obj.solution};
    res = {obj.results};
    sim = cell(1,nobj);

    % Check that the models are solved
    %-----------------------------------
    for ii = 1:nobj
        opt{ii} = opt{ii}(end); % The model may be estimated on real-time data, so here we only allow to simulate based on the full sample estimates
        if ~isfield(opt{ii},'estim_end_ind') % Some model may not be estimated
            opt{ii}.estim_end_ind   = 1;
            opt{ii}.estim_start_ind = 1;
            opt{ii}.estimator       = '';
            opt{ii}.recursive_estim = 0;
        end
    end

    % Check for exogenous variables which are not simulated
    %------------------------------------------------------
    condDB     = cell(1,nobj);
    shockProps = repmat({struct},[1,nobj]);
    condDBVar  = repmat({{}},1,nobj);
    for ii = 1:nobj
        if ~isfield(obj(ii).solution,'exo')
            error(['Cannot simulate an model of class ' class(obj(ii)), ...
                ', which is the class of the model ' names{ii}])
        end
        exo = obj(ii).solution.exo;
        if ~isempty(exo)
            ind = ismember(exo,{'Constant','Time-trend'});
            exo = exo(~ind);
            if ~isempty(exo)
                [~,indX]      = ismember(exo,opt{ii}.dataVariables);
                condDB{ii}    = opt{ii}.data(opt{ii}.estim_start_ind:opt{ii}.estim_end_ind,indX);
                condDBVar{ii} = exo;
                if nSteps > size(condDB{ii},1)
                    error([mfilename ':: Cannot simulate model ' int2str(ii) ' for more periods than the number '...
                                     'of data points (' int2str(size(condDB{ii},1)) ') of the exogenous variables (including burned periods)'])
                end
            end
        else
            if ~isempty(inputs(1).condDB)
                condDBVar{ii}  = inputs(1).condDB.variables;
                condDB{ii}     = double(inputs(1).condDB);
                shockProps{ii} = inputs(1).shockProps;
            end
        end
    end

    % Check for special nb_dsge models
    for ii = 1:nobj   
        if isa(obj(ii),'nb_dsge')
            if isBreakPoint(obj(ii))
                if isempty(inputs.startDate)
                    error([mfilename ':: If you are dealing with a DSGE model with break-points then the startDate input must be given.'])
                end
                % Minus one here to get the timing correct
                opt{ii}.dataStartDate = toString(nb_date.date2freq(inputs.startDate) - 1 - burn); 
            end 
        end
    end

    % Do simulation for each model
    %------------------------------------------------------
    if parallel
        ret = nb_openPool();
        parfor ii = 1:nobj
            sim{ii} = nb_forecast(sol{ii},opt{ii},res{ii},[],[],nSteps,inputs(ii),condDB{ii},condDBVar{ii},shockProps{ii});
        end
        nb_closePool(ret);
    else
        for ii = 1:nobj
            sim{ii} = nb_forecast(sol{ii},opt{ii},res{ii},[],[],nSteps,inputs(ii),condDB{ii},condDBVar{ii},shockProps{ii});
        end
    end

    % Assign objects
    %------------------------------------------------------
    out = struct;
    for ii = 1:nobj

        sData = sim{ii}.data(burn+1:end,:,1:end-removeMean,:);
        if isempty(obj(ii).name)
            n = ['Model' int2str(ii)];
        else
            n = obj(ii).name;
        end
        if ~isempty(inputs.startDate)
            try
                out.(n) = nb_ts(sData,'Simulation',inputs.startDate,sim{ii}.variables);
            catch %#ok<CTCH>
                n       = ['Model' int2str(ii)];
                out.(n) = nb_ts(sData,'Simulation',inputs.startDate,sim{ii}.variables);
            end
        else
            try
                out.(n) = nb_data(sData,'Simulation',1,sim{ii}.variables);
            catch %#ok<CTCH>
                n       = ['Model' int2str(ii)];
                out.(n) = nb_data(sData,'Simulation',1,sim{ii}.variables);
            end
        end
    end
      
end
