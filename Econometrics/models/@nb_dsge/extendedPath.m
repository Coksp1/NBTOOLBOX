function sim = extendedPath(obj,nSteps,varargin)
% Syntax:
%
% sim = extendedPath(obj,nSteps,varargin)
%
% Description:
%
% Perform simulation from a model using extended path.
% 
% Input:
% 
% - obj    : An object of class nb_dsge.
%
% - nSteps : Number of simulation steps. As a 1x1 double. Default is 100.
%
% Optional input:
%
% - 'blockDecompose'    : Set it to true to use block decomposition to 
%                         solve the problem.
%
% - 'derivativeMethod'  : Either 'symbolic' (fastest) or 'automatic'.
%
% - 'draws'             : Number of residual/innovation draws per 
%                         parameter draw. Default is 1000. Must be larger 
%                         than 0.
%
% - 'exogenousPerm'     : A cellstr with the exogenous variables of the 
%                         'exoPermVal' input.
%
% - 'exogenous'         : A cellstr with the exogenous variables of the 
%                         model to simulate. If empty, all exogenous
%                         variables are simulated. All shocks are 
%                         simulated from N(0,I).
%
% - 'exoPermVal'        : A N x nExo x draws double with the values  
%                         of the permament shocks to the exogenous  
%                         variables used by the simulations. The value at  
%                         each period is taken as the value that will be 
%                         used for the entire perfect foresight of one  
%                         step of the extended path simulation. If not 
%                         given or given as empty, no permanent shocks 
%                         will take place.
%
%                         Caution: N must be equal to nSteps.
%                         Caution: If this input only gives the values of
%                                  a subset of the exogenous variable, the
%                                  rest will be given 0 for all
%                                  observations.
%                         Caution: If this input is given, the end
%                                  point of perfect foresight simulation
%                                  is re-solved only when the permanent 
%                                  shock of this period has changed since
%                                  last period. This is done before the
%                                  loop of the extended path and can be 
%                                  done in parallel.
%
% - 'exoVal'            : A nPer x nExo x nSteps x draws double with  
%                         the values of the exogenous variables for the  
%                         simulations. If empty, the 'exogenous' input will 
%                         decide which exogenous variables that is to be 
%                         simulated, otherwise the 'exogenous' inputs set 
%                         the name of each column of this input.
%
%                         The third dimension will be equal to the number 
%                         of steps to simulate, i.e. it will overrun the 
%                         nSteps input.
%
%                         The fourth dimension will set the number of
%                         extended path simulations to be done, i.e. it
%                         will overrun the 'draws' input.
%
%                         Caution: If nPer < periods the values after
%                                  this observation gets the values 0.
%                         Caution: If this input only gives the values of
%                                  a subset of the exogenous variable, the
%                                  rest will be given 0 for all
%                                  observations.
%                         Caution: This input must has as many pages as 
%                                  the nSteps input, i.e. each page is
%                                  the set of anticipated shocks seen
%                                  at the given period of the extended 
%                                  path simulation.
%                         Caution: If this input us provided it will only
%                                  give one simulation, i.e. the 'draws'
%                                  is automatically set to 1.
%
% - 'homotopyAlgorithm' : See nb_dsge.help('homotopyAlgorithm'). Default
%                         is 0, i.e. no homotopy.
%
% - 'homotopySteps'     : See nb_dsge.help('homotopySteps'). Default
%                         is 10.
%
% - 'optimset'          : A struct with the options used by the solver.
%                         See nb_perfectForesight.optimset for more.
%
% - 'parallel'          : Give true if you want to do the simulations in 
%                         parallel. I.e. spread the simulation of the 
%                         different extended paths to different threads.
%                         Default is false.
%
% - 'periods'           : The number of periods of the simulation. E.g.
%                         periods >>> number of period it takes to 
%                         converge to the end values of the simulations.
%                         Default is 150.
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
% - 'startDate'         : Give the start date of the simulation. If not
%                         provided the output will be a nb_data object 
%                         without a spesific start date (default). If 
%                         provided the output will be an object of class 
%                         nb_ts.

% - 'startingValues'    : How to find the starting values of the problem
%                         to solve, i.e. the inital values of the full
%                         path.
%
%                         > 'steady_state' : All variables for all
%                           periods are set to theirs initial steady-state
%                           values. Default.
%
% Output:
% 
% - sim     : The extended path simulation results. Either as a nb_data or
%             nb_ts object.
%
% See also:
% nb_model_generic.perfectForesight, nb_dsge.simulate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handles a scalar nb_dsge object.'])
    end
    if ~isNB(obj)
        error([mfilename ':: This method is only supported for a DSGE model that has been parsed with NB Toolbox.'])
    end
    if isBreakPoint(obj)
        error([mfilename ':: Cannot call this method on a DSGE model with break-points.'])
    end
    if obj.parser.optimal
        error([mfilename ':: Cannot solve the perfect foresight problem when doing optimal policy'])
    end
    
    % Parse inputs
    inputs = parseInputs(obj,nSteps,varargin{:});
    
    % Solve and check initial steady-state
    obj = checkSteadyState(obj);
     
    % Initialize initVal struct to original steady-state
    stateVars      = obj.parser.endogenous(obj.parser.isBackwardOrMixed);
    init           = obj.solution.ss(obj.parser.isBackwardOrMixed);
    in             = cell(1,size(stateVars,2)*2);
    in(1:2:end)    = flip(stateVars,2);
    in(2:2:end)    = num2cell(flip(init,1));
    inputs.initVal = struct(in{:});
    
    % Get starting values for paths
    Y = nb_perfectForesight.getStartingValues(obj,inputs);
    
    % Get a function handle of the problem to solve
    [funcs,inputs] = nb_perfectForesight.getStackedSystemFunction(obj,inputs);
    
    % Solve for the end points
    inputSim = solveForEndPoints(obj,inputs);
    
    % Simulate the extended paths
    simD = simulateExtPaths(obj,inputSim,funcs,Y);
     
    % Create output
    if isempty(inputs.startDate)
        sim = nb_data(simD,'Simulation',1,obj.dependent.name);
    else
        sim = nb_data(simD,'Simulation',inputs.startDate,obj.dependent.name);
    end
    
end

%==========================================================================
function inputs = parseInputs(obj,nSteps,varargin)

    opt            = nb_perfectForesight.optimset('nb_solve');
    startingValues = {'steady_state'};
    default = {'blockDecompose',    false,             @nb_isScalarLogical;...
               'derivativeMethod',  'symbolic',        {{@nb_ismemberi,{'symbolic','automatic'}}};...
               'draws',             500,               @(x)nb_isScalarInteger(x,0);...
               'exogenous',         {},                @(x)iscellstr(x);...
               'exogenousPerm',     {},                @(x)iscellstr(x);...
               'exoPermVal',        [],                {@isnumeric,'||',@isempty};...
               'exoVal',            [],                {@isnumeric,'||',@isempty};...
               'homotopyAlgorithm', 0,                 @nb_isScalarInteger;...
               'homotopySteps',     10,                @(x)nb_isScalarInteger(x,1);...
               'optimset',          opt,               @isstruct;...   
               'parallel',          false,             @nb_isScalarLogical;...
               'periods',           150,               @(x)nb_isScalarInteger(x,0);...
               'seed',              1,                 @(x)nb_isScalarInteger(x,0);...
               'solver',            'nb_solve',        {{@nb_ismemberi,{'nb_solve','nb_abcSolve'}}};...
               'startDate',         '',                {@ischar,'||',@(x)isa(x,'nb_date')};...
               'startingValues',    'steady_state',    {{@nb_ismemberi,startingValues}};...
               'waitbar',           [],                {@(x)isa(x,'nb_waitbar'),'||',@isempty}};
                    
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    inputs.nSteps = nSteps;
    inputs        = checkExoVal(obj,inputs);
    inputs        = checkExoPermVal(obj,inputs);
    
    % Are we doing unexpected shocks?
    inputs.iterations   = 1;
    inputs.unexpected   = false;
    inputs.start        = 1;
    inputs.startExo     = 1;
    inputs.finish       = inputs.periods*obj.dependent.number;
    inputs.periodsUEndo = inputs.finish - inputs.start + 1;
    inputs.periodsU     = inputs.periods - inputs.startExo + 1;
    inputs.initValLoc   = 1:obj.dependent.number;
    
    % Initialize empty endVal struct
    controlVars   = obj.parser.endogenous(obj.parser.isForwardOrMixed);
    in            = cell(1,size(controlVars,2)*2);
    in(1:2:end)   = flip(controlVars,2);
    inputs.endVal = struct(in{:});
    inputs.ss     = nan(obj.dependent.number,1);
    
    % Add homotopy options
    inputs.fix_point_TolFun = obj.options.fix_point_TolFun;
    inputs                  = checkHomotopyOptions(inputs);
    
end

%==========================================================================
function inputs = checkHomotopyOptions(inputs)
    inputs.homotopy = logical(inputs.homotopyAlgorithm);
end

%==========================================================================
function inputs = checkExoVal(obj,inputs)

    exo  = obj.parser.exogenous;
    nExo = length(exo);
    if isempty(inputs.exoVal)
        % The exogenous variables are assumed to be N(0,I)!
        if isempty(inputs.exogenous)
            inputs.exoVal = [randn(1,nExo,inputs.nSteps,inputs.draws);
                             zeros(inputs.periods-1,nExo,inputs.nSteps,inputs.draws)];
        else
            [test,loc] = ismember(inputs.exogenous,exo);
            if any(~test)
                error([mfilename ':: The following variables, given by the exogenous input, ',...
                    'are not exogenous variables of the model; ' toString(inputs.exogenous(~test))]);
            end
            nExo               = length(inputs.exogenous);
            condExoData        = randn(1,nExo,inputs.nSteps,inputs.draws);
            exoData            = zeros(inputs.periods,nExo,inputs.nSteps,inputs.draws);
            exoData(1,loc,:,:) = condExoData;
            inputs.exoVal      = exoData;
        end
        return
    end

    inputs.draws = size(inputs.exoVal,4);
    pages        = size(inputs.exoVal,3);
    if pages ~= inputs.nSteps
        error([mfilename ':: If the exoVal input is not empty, it must ',...
            'have as many pages as the nSteps input (' int2str(inputs.nSteps) ').'])
    end
    exoData    = zeros(inputs.periods,nExo,inputs.nSteps,inputs.draws);
    [test,loc] = ismember(inputs.exogenous,exo);
    if any(~test)
        error([mfilename ':: The following variables, given to the exogenous input, ',...
            'are not exogenous variables of the model; ' toString(inputs.exogenous(~test))]);
    end
    indP                = 1:size(inputs.exoVal,1);
    exoData(indP,loc,:) = inputs.exoVal;
    inputs.exoVal       = exoData;
    
end

%==========================================================================
function inputs = checkExoPermVal(obj,inputs)

    exo  = obj.parser.exogenous;
    nExo = length(exo);
    if isempty(inputs.exoPermVal)
        % Default is no permanent shocks
        inputs.exoPermVal = zeros(inputs.periods,nExo,1);
        return
    end

    % Check
    pages = size(inputs.exoPermVal,3);
    if not(pages == 1 || pages == inputs.draws)
        error([mfilename ':: If the exoPermVal input is not empty, it must ',...
            'have only one page or ' int2str(inputs.draws) ' pages.'])
    end
    if size(inputs.exoPermVal,1) ~= inputs.nSteps
        error([mfilename ':: If the exoPermVal input is not empty, it must ',...
            'have as many observations as the nSteps input (' int2str(inputs.nSteps) ').'])
    end
    exoData    = zeros(inputs.nSteps,nExo,pages);
    [test,loc] = ismember(inputs.exogenousPerm,exo);
    if any(~test)
        error([mfilename ':: The following variables, given to the exogenousPerm input, ',...
            'are not exogenous variables of the model; ' toString(inputs.exogenousPerm(~test))]);
    end
    exoData(:,loc,:)  = inputs.exoPermVal;
    inputs.exoPermVal = exoData;
    
end

%==========================================================================
function inputs = solveForEndPoints(obj,inputs)

    exo             = obj.parser.exogenous;
    nExo            = length(exo);
    [uPerm,~,iPerm] = unique(reshape(inputs.exoPermVal,[inputs.nSteps,nExo*inputs.draws]),'rows');
    nUnique         = size(uPerm,1);
    
    % Initialize endVal struct
    endVal = inputs.endVal;
    endVal = endVal(1,ones(1,nUnique));

    % Get the final options
    options                    = obj.options;
    options.homotopyAlgorithm  = inputs.homotopyAlgorithm;
    options.homotopySteps      = inputs.homotopySteps;
    options.steady_state_init  = getSteadyState(obj,'','struct');
    options.steady_state_solve = true;
    
    % Other needed options
    pKnown     = getParameters(obj,'struct','reverse');
    paramVal   = obj.parameters.value;
    estOptions = obj.estOptions;
    
    % Solve for the new steady-states
    ss = nan(obj.dependent.number,nUnique);
    if inputs(1,1).parallel
    
        parfor ii = 1:nUnique
            opt                   = getOneOptions(options,uPerm(ii,:),exo);
            [endVal(ii),ss(:,ii)] = solveOneSteadyState(estOptions,opt,pKnown,paramVal);
        end

    else
        
        for ii = 1:nUnique
            opt                   = getOneOptions(options,uPerm(ii,:),exo);
            [endVal(ii),ss(:,ii)] = solveOneSteadyState(estOptions,opt,pKnown,paramVal);
        end
        
    end
    
    % Assign to inputs
    nSteps = inputs.nSteps;
    draws  = inputs.draws;
    inputs = inputs(ones(1,nSteps),ones(1,draws));
    kk     = 1;
    for ii = 1:nSteps
        for jj = 1:draws
            inputs(ii,jj).endVal = endVal(iPerm(kk));
            inputs(ii,jj).ss     = flip(ss(:,iPerm(kk)),1);
            kk                   = kk + 1;
        end
    end
    
end

%==========================================================================
function options = getOneOptions(options,uPerm,exo)

    % Get a struct of all permanent shock not set to 0
    ind   = uPerm == 0;
    if ~any(ind)
        options.steady_state_exo = [];
    else
        options.steady_state_exo = cell2struct(num2cell(uPerm(:,ind))',exo(ind));
    end
    
end

%==========================================================================
function [endVal,ss] = solveOneSteadyState(estOptions,options,pKnown,paramVal)

    % Get the homotopy setup
    if options.homotopyAlgorithm > 0
        homotopyNames         = fieldnames(options.steady_state_exo);
        options.homotopySetup = [homotopyNames,struct2cell(options.steady_state_exo)];
    else
        options.homotopySetup = {};
    end

    % Solve the steady-state after the permanent shock
    [ss,~,err] = nb_dsge.solveSteadyStateStatic(estOptions.parser,options,pKnown,false);
    if ~isempty(err)
        error([mfilename '::' err])
    end

    % Check steady-state
    err = nb_dsge.checkSteadyStateStatic(estOptions,paramVal,...
                    options.steady_state_tol,ss,options.steady_state_exo);
    if ~isempty(err)
        error('nb_dsge:steadyStateCheckFailed',err,'');
    end

    % Return the steady-state
    control = estOptions.parser.endogenous(estOptions.parser.isForwardOrMixed);
    ssC     = ss(estOptions.parser.isForwardOrMixed);
    endVal  = cell2struct(num2cell(flip(ssC,1)),flip(control,2));

end

%==========================================================================
function sim = simulateExtPaths(obj,inputs,funcs,Y)

    endo   = obj.parser.endogenous;
    sInd   = obj.parser.isBackwardOrMixed;
    states = flip(obj.parser.endogenous(obj.parser.isBackwardOrMixed),2);
    nEndo  = size(Y,1)/inputs(1,1).periods;
    draws  = size(inputs,2);
    nSteps = size(inputs,1);
    sim    = zeros(nSteps,nEndo,draws);
    indE   = nEndo + 1:nEndo*2;
    if inputs(1,1).parallel
        
        parfor ii = 1:draws
            
            inputsTT = inputs(:,ii);
            for tt = 1:nSteps
                
                % Do one perfect foresight simulation
                YT           = nb_perfectForesight.normalSolution(obj,Y,inputsTT(tt),funcs);
                sim(tt,:,ii) = YT(indE);
                y            = sim(tt,:,ii);
                
                % Set the initial observations for next period
                if tt < nSteps
                    inputsTT(tt+1).initVal = cell2struct(num2cell(flip(y(sInd),1))',states);
                end
                
            end
            
        end
        
    else
        
        for ii = 1:draws
            for tt = 1:nSteps
                
                % Do one perfect foresight simulation
                YT           = nb_perfectForesight.normalSolution(obj,Y,inputs(tt,ii),funcs);
                sim(tt,:,ii) = YT(indE);
                
                % Set the initial observations for next period
                if tt < nSteps
                    inputs(tt+1,ii).initVal = cell2struct(num2cell(flip(sim(tt,sInd,ii),2))',states);
                end
                
            end
        end
        
    end
        
end

