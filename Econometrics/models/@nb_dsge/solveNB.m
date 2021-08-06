function obj = solveNB(obj,varargin)
% Syntax:
%
% obj = solveNB(obj,varargin)
%
% Description:
%
% Solve for the decision rules under the assumption of rational 
% expectations.
% 
% See:
% "Solving rational expectations models at first order: what Dynare does" 
% by Sebastian Villemot.
%
% "Loose commitment in medium-scale macroeconomic models: Theory and an 
% application" by Debortoli, Maih and Nunes (2010).
%
% "DAG.pdf" by Kenneth Sæterhagen Paulsen.
%
% Input:
% 
% - obj : An object of class nb_dsge. The NB Toolbox parser must be used.
% 
% Optional inputs:
%
% - See the nb_model_estimate.set method.
%
% Output:
% 
% - obj : An object of class nb_dsge. See the solution property.
%
% See also:
% nb_dsge.solve, nb_dsge.optimalMonetaryPolicySolver, 
% nb_dsge.backwardSolver, nb_dsge.rationalExpectationSolver
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj  = set(obj,varargin{:});
    nobj = numel(obj);
    if nobj > 1
        obj = obj(:);
        for ii = 1:nobj
            obj = solveNB(obj);
        end
        return 
    end
    
    % Stationarized the model if it includes unit root variables
    if ~isStationary(obj)
        obj = stationarize(obj);
    end
    
    % Check if we are solving for anticipated shocks with an option to
    % reset the standrard deviation of the shocks
    expandedOnly = false;
    if ~isempty(obj.options.numAntSteps) && ~isempty(obj.options.shockProperties)
        obj = checkForUpdatedSTD(obj);
        if ~obj.needToBeSolved
            % Check if the expanded solution is already found or not
            if ~isfield(obj.solution,'CE')
                expandedOnly = true;
            else
                return
            end
        end
    else
        if ~obj.needToBeSolved
            return
        end
    end

    % Turn obs_model into a function handle
    if ~isempty(obj.parser.obs_equations) 
        obj = obsModel2func(obj);
    end
    
    % Solve for the steady-state
    if ~obj.steadyStateSolved
        obj = interpretSteadyStateInit(obj);
        obj = checkSteadyState(obj);
        if isfield(obj.solution,'ssOriginal')
            obj.solution = rmfield(obj.solution,'ssOriginal');
        end
    end
    
    % Compute derivatives of the dynamic model, if not already calculated
    if ~obj.takenDerivatives 
        obj = derivative(obj);
        
        % Block decompose model before for solving
        if obj.options.blockDecompose
            obj = blockDecompose(obj,false);
        end        
    end
    
    % Check model
    if obj.options.check
        % Check for equation that has been given more than once.
        for ii = 1:size(obj.solution.jacobian) 
            for jj = ii+1:size(obj.solution.jacobian)
                if all(obj.solution.jacobian(ii,:) == obj.solution.jacobian(jj,:))
                    disp(obj.parser.equations{ii})
                    disp(obj.parser.equations{jj})
                    error([mfilename ':: The above equation are equal.'])
                end
            end
        end
    end
    
    % Solve
    %----------------------------------------------------------------------
    silent = obj.options.silent;
    if ~silent
        t = tic;
        disp(' ')
        disp('Solving for the decision rules:')
    end
    
    if obj.parser.hasExpectedBreakPoints
        % In this case we need the parameter values, so we store them
        % temporarily in obj.parser
        obj.parser.beta = obj.results.beta;
    end
    
    if ~isempty(obj.options.discount)
        obj.options.discount = nb_dsge.setDiscount(obj.options.discount,obj.parser.parameters,obj.results.beta);
    end
    
    
    if isBreakPoint(obj) && expandedOnly
        
        % Solve for the expanded solution only
        CE = cell(1,obj.parser.nBreaks+1);
        for ii = 1:obj.parser.nBreaks+1
            sol                    = getRegime(obj.solution,ii);
            [~,~,~,CE{ii},~,~,err] = nb_dsge.selectSolveAlgorithm(obj.parser,sol,obj.options,expandedOnly);
            if ~isempty(err)
                error(err)
            end
        end
        obj.solution.CE = CE;
        if ~silent
            elapsedTime = toc(t);
            disp(['Finished in ' num2str(elapsedTime) ' seconds'])
        end
        
    else
        
        % Solve for the decision rules
        [A,B,C,CE,ss,parser,err] = nb_dsge.selectSolveAlgorithm(obj.parser,obj.solution,obj.options,expandedOnly);
        if ~isempty(err)
            error(err)
        end

        if ~silent
            elapsedTime = toc(t);
            disp(['Finished in ' num2str(elapsedTime) ' seconds'])
        end
        
        % Do we have any break-points?   
        if obj.parser.nBreaks > 0 && ~obj.parser.hasExpectedBreakPoints
            obj.options.parser        = obj.parser; 
            [A,B,C,CE,ss,JAC,sol.err] = nb_dsge.solveBreakPoints(obj.options,obj.results.beta,A,B,C,CE,ss,obj.solution.jacobian,obj.options.silent);
            if ~isempty(sol.err)
                error('solveNB:Failed',sol.err,'');
            end
            obj.solution.jacobian     = JAC;
            obj.solution.breaks       = [obj.parser.breakPoints.date];
            obj.options               = rmfield(obj.options,'parser');
        end
        
        if obj.parser.optimal
        
            % Update model due to the added multipliers
            obj.parser = parser;
            obj        = updateGivenOptimalPolicy(obj);

            % Add the steady-state values of the multipliers, only done if
            % steady-state is updated
            if ~isfield(obj.solution,'ssOriginal')
                obj.solution.ssOriginal = ss;
                if iscell(ss)
                    for ii = 1:length(ss)
                        ss{ii} = [ss{ii};zeros(sum(obj.parser.isMultiplier),1)];
                    end
                else
                    ss = [obj.solution.ss;zeros(sum(obj.parser.isMultiplier),1)];
                end
            end

        end
        
        % Assign solution to object
        obj.solution.A  = A;
        obj.solution.B  = B;
        obj.solution.C  = C;
        obj.solution.ss = ss;
        if iscell(CE)
            CET = CE{1};
        else
            CET = CE;
        end
        if ~isempty(CET)
            obj.solution.CE = CE;
        end

    end
    
    % Update other properties of the solution
    obj = fullSolution(obj);
    if ~isempty(obj.parser.obs_equations)
        obj = updateGivenObsModel(obj);
    end
    
    % Indicate that the model does not need to be re-solved
    obj.needToBeSolved = false;
    if obj.parser.hasExpectedBreakPoints
        obj.parser = rmfield(obj.parser,'beta');
    end
    
end

%==========================================================================
function obj = checkForUpdatedSTD(obj)

    if ~isfield(obj.options.shockProperties,'StandardDeviation')
        obj.solution.activeShocks = true(1,length(obj.solution.res));
        return
    end
    shockProperties = obj.options.shockProperties;
    param           = struct();

    % Check for removed shocks
    [test,locR] = ismember(obj.solution.res,{shockProperties.Name});
    if any(~test)
        error([mfilename ':: the shockProperties input must contain all the shocks of the model! Missing; ' toString(obj.solution.res(~test))])
    end
    stds = [shockProperties.StandardDeviation];
    stds = stds(locR);
    indA = stds ~= 0;
    
    % Time to set each shock to its standard
    shockProperties = shockProperties(indA);
    res             = obj.solution.res;
    ShockNames      = {shockProperties.Name};
    for j = 1:numel(ShockNames)

        sj    = ShockNames{j};
        sj_id = find(strcmp(sj, res),1);
        if isempty(sj_id)
            error([mfilename,':: shock ',sj,' is undeclared'])
        end

        % standard deviation
        if isfield(shockProperties(j),'StandardDeviation')
            if ~isnan(shockProperties(j).StandardDeviation)
                sname         = ['std_' sj]; % This is not too general, is it?
                param.(sname) = shockProperties(j).StandardDeviation;
            end
        end

    end

    % Reset standard deviation if wanted
    if ~nb_isempty(param)
        obj = assignParameters(obj,param); % This will set needToBeSolved == true
    end
    obj.solution.activeShocks = indA;

end

%==========================================================================
function sol = getRegime(sol,ii)
    % Return solution to one regime only
    sol.A        = sol.A{ii};
    sol.B        = sol.B{ii};
    sol.C        = sol.C{ii};
    sol.ss       = sol.ss{ii};
    sol.jacobian = sol.jacobian{ii}; 
end
