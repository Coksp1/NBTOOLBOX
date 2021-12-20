function [sim,plotter,distr] = perfectForesight(obj,varargin)
% Syntax:
%
% [sim,plotter,distr] = perfectForesight(obj,varargin)
%
% Description:
%
% Perform perfect foresight simulation.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
%
% Optional input:
%
% - 'addEndVal'         : Add end value as the last observation of the
%                         simulation results, i.e. if the 'periods' input
%                         is set to 100, the sim output will return a
%                         nb_data object with 101 observation. nan is given
%                         to the variable not assign a end value with the
%                         'endVal' input. Default is true.
%
% - 'addSS'             : Set to false to not add the steady-state to 
%                         the simulation. Default is true.
%
% - 'blockDecompose'    : Set it to true to use block decomposition to 
%                         solve the problem.
%
% - 'derivativeMethod'  : Either 'symbolic' (fastest) or 'automatic'.
%
% - 'draws'             : Number of draws from the distribution of the
%                         initial values. Default is 500. See 
%                         'stochInitVal'.  
%
% - 'endVal'            : Sets the end values of the simulation of all the
%                         endogenous variables of the model. Must be given  
%                         as a struct where the fieldnames are the names
%                         of the endogenous variables of the model,
%                         and the fields are their end value. If not
%                         provided the end values will be the original
%                         steady-state. See the nb_dsge.getEndVal
%                         method to find the end values after a permanent
%                         shock.
%
% - 'exoVal'            : A nb_data object with the values of the 
%                         exogenous variable for the wanted simulation.
%
%                         Caution: If startObs > 1, the values before this
%                                  observation gets the values 0.
%                         Caution: If endObs < periods the values after
%                                  this observation gets the values 0.
%                         Caution: If this input only gives the values of
%                                  a subset of the exogenous variable, the
%                                  rest will be given 0 for all
%                                  observations.
%                         
% - 'homotopyAlgorithm' : See nb_dsge.help('homotopyAlgorithm'). Default
%                         is 0, i.e. no homotopy.
%
% - 'homotopySteps'     : See nb_dsge.help('homotopySteps'). Default
%                         is 10.
%
% - 'initVal'           : Sets the initial values of the simulation of all 
%                         the backward looking variables. Must be given as  
%                         a struct where the fieldnames are the names
%                         of the backward looking variables of the model,
%                         and the fields are their initial value. If not
%                         provided the initial values will be the original
%                         steady-state.
%
%                         Caution: If 'stochInitVal' is set to true, this
%                                  option will set the conditional
%                                  information of the initial condition.
%                                  For more on this case see doc on the
%                                  input 'stochInitVal'.
%
% - 'optimset'          : A struct with the options used by the solver.
%                         See nb_perfectForesight.optimset for more.
%
% - 'periods'           : The number of periods of the simulation. E.g.
%                         periods >>> number of period it takes to 
%                         converge to the end values of the simulations.
%                         Default is 150.
%
% - 'plotInitSS'        : Plot initial steady-state in the return graphs,
%                         if 'addSS' is set to false, zero lines will be
%                         plotted. The period 0 will also be included, and
%                         will be set to the initial steady-state (zero).
%                         true or false. Default is false.
%
% - 'plotSS'            : Plot steady-state values during simulation.
%                         'plotInitSS' will be set to true in this case.
%
% - 'seed'              : Set the seed of the pseudo random generated
%                         numbers when 'stochInitVal' is set to true.
%                         Default is 1.
%
% - 'solver'            : Name of the solver to use. Either 'nb_solve' or
%                         'nb_abcSolve'. Default is 'nb_solve', i.e.
%                         using newton algorithm. See the 'optimset' 
%                         options to adjust solving options.
%
% - 'startingValues'    : How to find the starting values of the problem
%                         to solve, i.e. the inital values of the full
%                         path.
%
%                         > 'steady_state' : All variables for all
%                           periods are set to theirs initial steady-state
%                           values. Default.
%
% - 'stochInitVal'      : Set to true to draw initial conditions. If
%                         'initVal' is not provided it will draw from
%                         unconditional distribution of the initial 
%                         condition, or else it will draw from the 
%                         conditional distribution of the initial values.
%                         In the latter case you can fix the value of a
%                         variable by giving a scalar double to a field
%                         of the 'initVal' input, or you can spesify 
%                         a truncated interval by provided a 1x2 double
%                         with the lower and upper bound to a field of
%                         of the 'initVal' input. E.g:
%
%                         1. Condition on a point: init.Var1 = 2;
%                         2. Condition on a interval: init.Var1 = [1.5,2.5];
%
% Output:
% 
% - sim     : The perfect foresight simulation stored as a periods x nVar 
%             nb_data object
%
% - plotter : A nb_graph_data object. Use the graphSubPlots method or
%             the nb_graphSubPlotGUI class to produce the figures.
%
% See also:
% nb_model_generic.irf, nb_dsge.getEndVal, nb_dsge.checkSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    distr = [];
    if numel(obj) > 1
        error([mfilename ':: This method only handles a scalar nb_dsge object.'])
    end
    if ~isNB(obj)
        error([mfilename ':: This method is only supported for a DSGE model that has been parsed with NB Toolbox.'])
    end
    if isBreakPoint(obj)
        error([mfilename ':: Cannot call this method on a DSGE model with break-points.'])
    end
    if ~isfield(obj.solution,'ss')
        error([mfilename ':: You first need to solve for the initial steady-state.'])
    end
    if obj.parser.optimal
        error([mfilename ':: Cannot solve the perfect foresight problem when doing optimal policy'])
    end
    name = getModelNames(obj);
    name = name{1};
    
    % Parse the inputs
    inputs = parseInputs(obj,varargin{:}); 
    silent = obj.options.silent;
    if ~silent
        tic;
        extra = '';
        if ~isempty(obj.name)
            extra = [' ' obj.name];
        end
        if inputs.unexpected
            extra = [extra '\n(With unexpected shocks)'];
        end
        fprintf(['Solving the perfect foresight problem of the model' extra '...\n'])
    end
    
    if any(obj.parser.isAuxiliary)
        parserT                    = nb_dsge.getLeadLag(obj.parser);
        obj.parser.equationsParsed = parserT.equationsParsed;
    end
    
    % Get starting values for paths
    Y = nb_perfectForesight.getStartingValues(obj,inputs);
    
    % Solve the problem
    if obj.parser.nForwardOrMixed == 0 
        % Purly backward looking model, which means we can use a much more 
        % efficient and robust solver
        if inputs.stochInitVal
            error([mfilename ':: Setting ''stochInitVal'' to true is not yet supported for purly backward looking models.'])
        end
        Y = nb_perfectForesight.forwardSolution(obj,Y,inputs);
    else
        if inputs.blockDecompose
            if inputs.stochInitVal
                error([mfilename ':: Setting ''stochInitVal'' and ''blockDecompose'' both to true is not supported.'])
            end
            Y = nb_perfectForesight.blockSolution(obj,Y,inputs);
        else 
            % Get a function handle of the problem to solve
            [funcs,inputs] = nb_perfectForesight.getStackedSystemFunction(obj,inputs);
            
            % Solve for the full path
            if inputs.stochInitVal
                Y = nb_perfectForesight.normalSolutionStochInitVal(obj,Y,inputs,funcs);
            else
                Y = nb_perfectForesight.normalSolution(obj,Y,inputs,funcs);
            end
        end
    end
    
    % Make it into a nb_data object
    if inputs.plotSS || inputs.plotInitSS
        start = 0;
    else
        start = 1;
    end
    sim = nb_data(getOutput(obj,inputs,Y),name,start,obj.dependent.name);
    if inputs.stochInitVal
        distr = sim;
        if sim.numberOfDatasets > 0
            sim = callstat(sim,@(x)mean(x,3),'name',name);
        end
    end
    
    % Reporting
    if inputs.plotSS
            
        ssData      = nan(sim.numberOfObservations,obj.dependent.number);
        ssData(1,:) = getSteadyState(obj,obj.dependent.name,'double')';
        for ii = 1:size(inputs.ss,2)
            if size(inputs.startExo,2) == ii
                finish = inputs.periods + 1;
                if inputs.addEndVal
                    finish = finish + 1;
                end
            else
                finish = inputs.startExo(ii+1);
            end
            ssData(inputs.startExo(ii)+1:finish,:) = repmat(inputs.ss(:,ii)',[finish - inputs.startExo(ii),1]);
        end
        ssDataObj = nb_data(ssData,[name '(SS)'],sim.startObs,obj.dependent.name);
        sim       = addPages(sim,ssDataObj);
        
    end
    if ~isempty(obj.reporting)
        sim = createVariable(sim,obj.reporting(:,1)',obj.reporting(:,2)');
        if inputs.stochInitVal
            distr = createVariable(distr,obj.reporting(:,1)',obj.reporting(:,2)');
        end
    end
    
    % Remove initial steady-state
    if ~inputs.addSS
        expr = sim.variables;
        if ~isempty(obj.reporting)
            [~,loc]   = ismember(obj.reporting(:,1)',expr);
            expr(loc) = obj.reporting(:,2)';
        end
        ss       = getSteadyState(obj,expr,'double')';
        sim.data = bsxfun(@minus,sim.data,ss);
        if inputs.stochInitVal
            distr.data = bsxfun(@minus,distr.data,ss);
        end
    end
    
    % Make plotter object
    if nargout > 1
        
        plotted = sim;
        if inputs.plotSS
            sim = sim(:,:,1);
        end
        plotter = nb_graph_data(plotted);
        plotter.set('parameters',getParameters(obj,'struct'));
        if inputs.stochInitVal
            plotter.set('fanDatasets',distr);
        end
        
    end
    
    if ~silent
        elapsedTime = toc;
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
        disp(' ')
    end

end

%==========================================================================
function inputs = parseInputs(obj,varargin)

    opt            = nb_perfectForesight.optimset('nb_solve');
    startingValues = {'steady_state'};
    default = {'addEndVal',         true,              @nb_isScalarLogical;...
               'addSS',             true,              @nb_isScalarLogical;...
               'blockDecompose',    false,             @nb_isScalarLogical;...
               'derivativeMethod',  'symbolic',        {{@nb_ismemberi,{'symbolic','automatic'}}};...
               'draws',             500,               @(x)nb_isScalarInteger(x,0);...
               'endVal',            struct,            {@isstruct,'||',@isempty};...
               'exoVal',            [],                {{@isa,'nb_data'},'||',@isempty};...
               'homotopyAlgorithm', 0,                 @nb_isScalarInteger;...
               'homotopySteps',     10,                @(x)nb_isScalarInteger(x,1);...
               'initVal',           struct,            {@isstruct,'||',@isempty};...
               'nLags',             0,                 @(x)nb_isScalarInteger(x,-1,2);...
               'optimset',          opt,               @isstruct;...              
               'periods',           150,               @(x)nb_isScalarInteger(x,0);...
               'plotInitSS',        false,             @nb_isScalarLogical;...
               'plotSS',            false,             @nb_isScalarLogical;...
               'seed',              1,                 @(x)nb_isScalarInteger(x,0);...
               'solver',            'nb_solve',        {{@nb_ismemberi,{'nb_solve','nb_abcSolve'}}};...
               'startingValues',    'steady_state',    {{@nb_ismemberi,startingValues}};...
               'stochInitVal',      false,             @nb_isScalarLogical;...
               'waitbar',           [],                {@(x)isa(x,'nb_waitbar'),'||',@isempty}};
                    
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    if inputs.stochInitVal
        inputs = checkStochInitVal(obj,inputs);
    else
        inputs = checkInitVal(obj,inputs);
    end
    inputs = checkEndVal(obj,inputs);
    inputs = checkExoVal(obj,inputs);
    
    % Are we doing unexpected shocks?
    if length(inputs.endVal) > 1
        
        if length(inputs.endVal) ~= size(inputs.exoVal,3)
            error([mfilename ':: The length of the struct array given to the endVal (' int2str(length(inputs.endVal)) ...
                             ') and the number of pages of the exoVal (' int2str(size(inputs.exoVal,3)) ') input must match!'])
        end
        inputs.iterations = size(inputs.exoVal,3);
        inputs.unexpected = true;
        
        % Get start, finish and number of periods of each subperiod
        nEndo       = obj.dependent.number;
        start       = nan(1,inputs.iterations);
        start(1)    = 1;
        startExo    = start;
        startExo(1) = 0; % 1 is added later
        for ii = 2:inputs.iterations 
            startExo(ii) = (find(~any(isnan(inputs.exoVal(:,:,ii)),2),1) - 1);
            start(ii)    = startExo(ii)*nEndo + 1;
        end
        inputs.startExo = startExo + 1;
        inputs.start    = start;
        inputs.finish   = [start(2:end)-1,inputs.periods*nEndo];
               
    else
        inputs.iterations = 1;
        inputs.unexpected = false;
        inputs.start      = 1;
        inputs.startExo   = 1;
        inputs.finish     = inputs.periods*obj.dependent.number;
    end
    inputs.periodsUEndo = inputs.finish - inputs.start + 1;
    inputs.periodsU     = inputs.periods - inputs.startExo + 1;
    
    % Add homotopy options
    inputs.fix_point_TolFun = obj.options.fix_point_TolFun;
    inputs                  = checkHomotopyOptions(inputs);
    
end

%==========================================================================
function inputs = checkHomotopyOptions(inputs)
    inputs.homotopy = logical(inputs.homotopyAlgorithm);
end

%==========================================================================
function sim = getOutput(obj,inputs,Y)

    nSim  = size(Y,3);
    nEndo = obj.dependent.number;
    sim   = permute(reshape(Y,[nEndo,inputs.periods,nSim]),[2,1,3]);
    if inputs.plotSS || inputs.plotInitSS
        if isfield(inputs,'initValDraws')
            initVal = permute(inputs.initValDraws,[3,2,1]);
        else
            initVal = cell2mat(struct2cell(inputs.initVal(1)))';
        end
        ss          = getSteadyState(obj,'','double')';
        ss          = flip(ss,2);
        ss          = ss(:,:,ones(1,nSim));
        loc         = inputs.initValLoc;
        ss(:,loc,:) = initVal;
        sim         = [ss;sim];
    end
    if inputs.addEndVal
        endVars      = fieldnames(inputs.endValIn);
        endVals      = nan(1,size(sim,2));
        endV         = cell2mat(struct2cell(inputs.endValIn(end)));
        [t,loc]      = ismember(endVars,obj.dependent.name);
        loc          = loc(t);
        endV         = endV(t);
        endVals(loc) = endV;
        endVals      = endVals(:,:,ones(1,nSim));
        sim          = [sim;endVals];
    end  
        
end

%==========================================================================
function inputs = checkEndVal(obj,inputs)

    % Check if it is a control variable
    endo    = obj.parser.endogenous;
    control = obj.parser.endogenous(obj.parser.isForwardOrMixed);
    endVars = fieldnames(inputs.endVal);
    ind     = ismember(endo,endVars);
    if any(~ind)
        missing   = endo(~ind);
        ssMissing = getSteadyState(obj,missing);
        ssMissing = vertcat(ssMissing{:,2});
        for pp = 1:length(inputs.endVal)
            for ii = 1:length(missing)
                inputs.endVal(pp).(missing{ii}) = ssMissing(ii);
            end
        end
    end
    
    % Store all values of the steady-state
    inputs.endVal = orderfields(inputs.endVal);
    ss            = nan(length(endo),length(inputs.endVal));
    for ii = 1:length(inputs.endVal)
    	ss(:,ii) = cell2mat(struct2cell(inputs.endVal(ii)));
    end
    inputs.ss = flip(ss,1);
    
    % Order the fields
    inputs.endValIn = inputs.endVal;
    inputs.endVal   = nb_keepFields(inputs.endVal,control);
    
end

%==========================================================================
function inputs = checkExoVal(obj,inputs)

    exo  = obj.parser.exogenous;
    nExo = length(exo);
    if isempty(inputs.exoVal)
        inputs.exoVal = zeros(inputs.periods,nExo,length(inputs.endVal));
        return
    end

    % Check
    pages    = inputs.exoVal.numberOfDatasets;
    exoData  = zeros(inputs.periods,nExo,pages);
    exoStart = inputs.exoVal.startObs;
    if pages > 1
        if exoStart > 1
            error([mfilename ':: If you supply a multi-paged nb_data object to the exoVal input it must ',...
                             'start at observation 1.'])
        end
    end
    exoEnd = inputs.exoVal.endObs;
    if exoEnd > inputs.periods
        error([mfilename ':: The exoVal input cannot have a end obs (' int2str(exoEnd) ...
            ') greater than the periods input (' int2str(inputs.periods) ')']);
    end
    condExo    = inputs.exoVal.variables;
    [test,loc] = ismember(condExo,exo);
    if any(~test)
        error([mfilename ':: The following variables, given to the exoVal input, are not exogenous; ' toString(condExo(~test))]);
    end
    condExoData         = double(inputs.exoVal);
    indP                = exoStart:exoEnd;
    exoData(indP,loc,:) = condExoData;
    inputs.exoVal       = exoData;
    
end

%==========================================================================
function inputs = checkInitVal(obj,inputs)

    % Check if it is a state variable
    state    = obj.parser.endogenous(obj.parser.isBackwardOrMixed);
    initVars = fieldnames(inputs.initVal);
    ind      = ismember(state,initVars);
    if any(~ind)
        missing   = state(~ind);
        ssMissing = getSteadyState(obj,missing);
        ssMissing = vertcat(ssMissing{:,2});
        for ii = 1:length(missing)
            inputs.initVal.(missing{ii}) = ssMissing(ii);
        end
    end
    
    % Order the fields
    inputs.initVal        = orderfields(inputs.initVal);
    [~,inputs.initValLoc] = ismember(fieldnames(inputs.initVal),obj.parser.endogenous);
    
end

%==========================================================================
function inputs = checkStochInitVal(obj,inputs)

    % Check if it is a state variable
    states   = flip(obj.parser.endogenous(obj.parser.isBackwardOrMixed),2);
    vars     = flip(obj.parser.endogenous,2);
    [~,locS] = ismember(states,vars);
    nVars    = size(vars,2);
    initVars = fieldnames(inputs.initVal);
    test     = ismember(initVars,vars);
    if any(~test)
        warning('nb_dsge:perfectForesight:notAStateVariable',...
            [mfilename ':: You have provided (a) fieldname(s) to the input ',...
            'initVal that is not (a) variable(s) of the model.'])
        initVars = initVars(test);
    end
    indC = false(nVars,1);
    a    = nan(nVars,1);
    l    = -inf(nVars,1);
    u    = inf(nVars,1);
    mu   = getSteadyState(obj,vars,'double');
    for ii = 1:size(initVars,1)
    
        ind   = strcmp(initVars{ii},vars);
        value = inputs.initVal.(initVars{ii});
        if nb_isScalarNumber(value)
            % Hard conditioning
            indC(ind) = true;
            a(ind)    = value;
        elseif isnumeric(value) && nb_sizeEqual(value,[1,2])
            % Soft conditioning
            l(ind) = value(1);
            u(ind) = value(2);
            if l(ind) >= u(ind)
                error([mfilename ':: Upper bound of the variable ' initVars{ii},...
                                 ' must be greater than the lower bound.'])
            end
        else
            error([mfilename ':: Improper value given to the fieldname ' initVars{ii}...
                ' of the ''intiVal'' input.'])
        end
        
    end
    
    % Get the theoretical covariance matrix of the model (This must come
    % from the linearized model!)
    if ~issolved(obj)
        try
            silentOld          = obj.options.silent;
            obj.options.silent = true;
            obj                = solve(obj);
            obj.options.silent = silentOld;
        catch Err
            nb_error([mfilename ':: Model need to be (linearized and) solved to be ',...
                                'able to simulate the initial conditions.'],Err)
        end
    end
    if inputs.nLags > 0
        sigma = theoreticalMoments(obj,'vars',vars,'output','double',...
                                       'type','covariance','stacked',true,...
                                       'nLags',inputs.nLags);
    else
        [~,sigma] = theoreticalMoments(obj,'vars',vars,'output','double',...
                                           'type','covariance');
    end
    
    if inputs.nLags > 0
       mu   = repmat(mu,[inputs.nLags + 1,1]);
       l    = [-inf(nVars*inputs.nLags,1);l];
       u    = [inf(nVars*inputs.nLags,1);u];
       indC = [false(nVars*inputs.nLags,1);indC];
       a    = [nan(nVars*inputs.nLags,1);a];
    end
                                   
    if all(sigma(:) == 0)
        error([mfilename ':: Your model is deterministic, so there is no ',...
                         'way to simulate the initial condition, as this need ',...
                         'a linearized stochastic version of the model.'])
    end
    
    % Simulate the initial values
    rng(inputs.seed); % Set the seed of the pseudo random numbers
    initDraws = nb_mvtncondrand(inputs.draws,1,mu,sigma,l,u,indC,a(indC));
    initDraws = initDraws(:,end-nVars+1:end);
    initDraws = initDraws(:,locS);
    
    % Assign back to initVal input
    inputs.initVal      = cell2struct(num2cell(initDraws)',states);
    inputs.initValDraws = initDraws;
    
    % Order the fields
    [~,inputs.initValLoc] = ismember(fieldnames(inputs.initVal),obj.parser.endogenous);
    
end
