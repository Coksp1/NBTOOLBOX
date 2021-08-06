classdef nb_abcSolve < handle
% Description:
%
% An implimentation of the artificial bee colony algorithm for solving
% a multivariate non-linear system of equations.
% 
% References: 
%
% "A comprehensive survey: Artificial bee colony (ABC) algorithm and 
% applications", Karaboga et. al (2012).
%
% "Modified artificial bee colony algorithm for constrained problems 
% optimization", Stanarevic et. al (2015)
%
% This class tries to solve the following problem
%
% F(x) = 0
% x in S    
%
% where F(x) is a set of non-linear solutions. S is the search space, i.e. 
% the space to look for candidate values to solve F(x) = 0.
%
% Caution: The steps of this implementation is slightly different from that
%          of Karaboga et. al (2012).
%
%          Initialize employed bees by scouting.
%
%          Repeat:
%
%          1. Employed bees that has reached the cutLimit are sent out
%             scouting. See nb_beeSolver.scout (local == false) or 
%             nb_beeSolve.joinDance (local == true).
%          2. Send onlookers to join the employed bees by random. Higher
%             probabilities are assign to the employed bees that  
%             communicates good values of the objective. Finally onlookers  
%             are sent to explore the neighbourhood of the selected 
%             employed bee  See nb_beeSolver.joinDance.
%          3. Employed bees are then sent to explore their neighbourhood 
%             by changing the current value of x. This is done by changing 
%             a random number of elements in x, the move is selected using 
%             x(n) = x(n-1) + alpha*F(x), where alpha is random search 
%             direction matrix. Each element is drawn from the uniform 
%             distribution in [-1,1]. See nb_beeSolver.dance.
%          4. All the new points of the bees are evaluated. (This is the
%             step that can be ran in parallel.)
%          5. The solution is then selected and stored. 
%
%          This is repeated until some of the limits (maxTime, maxFunEvals,
%          maxIter, maxSolutions or maxTimeSinceUpdate are reached).
%
% Superclasses:
%
% handle
%
% Constructor:
%
%   obj = nb_abcSolve(fh,init,lb,ub)
%   obj = nb_abcSolve(fh,init,lb,ub,options,varargin) 
%   obj = nb_abcSolve(fh,init,[],[],options,varargin)
% 
%   Input:
%
%   - fh       : See the dcumentation of the objective property of the 
%                nb_abcSolve class. 
%
%   - init     : See the dcumentation of the initialXValue property of the 
%                nb_abcSolve class.
%
%   - lb       : See the dcumentation of the lowerBound property of the 
%                nb_abcSolve class.
%
%   - ub       : See the dcumentation of the upperBound property of the 
%                nb_abcSolve class.
%
%   - options  : See the nb_abcSolve.optimset method for more on this 
%                input.
% 
%   Optional inputs:
%
%   - varargin : Optional number of inputs given to the objective when 
%                it is called during the minimization algorithm.
%
%   Output:
% 
%   - obj : An object of class nb_abcSolve.
% 
% See also: 
% nb_abcSolve.optimset, nb_abcSolve.call, nb_solve, fsolve 
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)

        % Positive integer. The maximum trial that is allowed for employed
        % bee before it starts to scout for another area. Default is 20.
        % Must be greater than 4.
        cutLimit 
        
        % 'iter' Level of display. 'iter' displays output at each 
        % iteration. Only supported option.
        display             
        
        % An object of class nb_optimizerDisplayer. This object set the way
        % the optimizer displayes result during the optimization.
        displayer   
        
        % This set the share of employed bees. Default is 0.33, i.e. 33%.
        % Must be in the set (0.1,0.9).
        employedShare 
        
        % A function handle that return the fitness of each bee at each
        % iteration of the optimization. See for example 
        % nb_fitness.standard, which is the default fitness function.
        % Other proper fitness functions may be found in the nb_fitness
        % package.
        fitnessFunc
        
        % This set the value of the fitness scaling parameter. Default is
        % 1. This is the third input to the function given by the 
        % fitnessFunc property.
        fitnessScale 
        
        % A function handle that return the jacobian at the current
        % evaluation point. Must return a N x N double or sparse matrix.
        % Default is [], i.e. the newton type bees used a Steffensen 
        % update instead.
        jacobianFunction
        
        % Use the algorithm for finding a local solutions, i.e. if set
        % to true, this will not search globally in S, but instead search
        % for a solution in the neighborhood of the current best candidate
        % of the emplyed bees. During initialization the bees are not sent
        % out to search the full space S at random, but instead doing
        % random small steps away from the inital value.
        local
        
        % Positive integer. Maximum number of function evaluation allowed. 
        % Default is inf.
        maxFunEvals
        
        % Positive integer. Maximum number of iterations allowed. Default 
        % is inf.
        maxIter
        
        % Positive integer. The number of bees to use during optimization. 
        maxNodes
        
        % Positive integer. The maximum number of solutions to allow. To
        % trigger a local solution algorithm set this to 1 and local to
        % true. Default is 20.
        maxSolutions
        
        % Positive integer. The maximum time spent on optimization in 
        % seconds. Default is 60 seconds.
        maxTime
        
        % Positive integer. The maximum time spent on optimization since
        % last time the minimum point where updated (in seconds).
        maxTimeSinceUpdate
        
        % Positive integer. The maximum trial that is allowed for finding
        % initial candidates. Default is 100.
        maxTrials
        
        % A function handle with the merit function to be applied to test
        % for solution candidates. A G : R^N -> R function. Default is
        % @(x)norm(x,2).
        meritFunction 
        
        % Positive integer. The minimum number of solutions to find. An
        % negative exitFlag will be thrown if the number of solutions are
        % not greater then or equal to this number. Default is 1.
        minSolutions
        
        % Share of employed bees being of newton type, i.e. use a newton
        % step of getting a new solution candidate instead of random 
        % search in the dancing area. If the derivative of the function 
        % F(x) is everywhere defined, you should set it to 1. Default is
        % 0.1, i.e. 10%.
        newtonShare
        
        % Set to true to make the employed bees that uses newton update
        % to move to convert too random shearch if they breach the 
        % cutLimit without finding a solution to the problem.
        newtonStop
        
        % Positive integer. Number of worker to use when running 
        % optimization in parallel.
        numWorkers
        
        % Double. If the objective return a value greater than this, a new
        % candidate of x is drawn. Default is 1e9.
        objectiveLimit
        
        % Tolerance value for accepting a solution.
        tolerance
        
        % Tolerance value for differencing between different solutions.
        toleranceX
        
        % true or false. Give true if the nodes should be spread on 
        % different parallel workers.
        useParallel
        
    end
        
    properties
       
        % The initial values of the optimization. Default is zero. As a 
        % N x 1 double.
        initialXValue       = 0;
        
        % The lower bound on the x values. As a N x 1 double. Must be
        % finite!
        lowerBound          = [];
        
        % The function to solve. As a function handle. Must take a N x 1 
        % double as the first input, and return a N x 1 double.
        F                   = [];
        
        % A struct with the options of the optimiziation. See the
        % nb_abcSolve.optimset method for more on this option.
        options             = nb_abcSolve.optimset();
        
        % The upper bound on the x values. As a n x 1 double. Must be
        % finite!
        upperBound          = [];
        
    end
    
    properties (SetAccess = protected)
        
        % A vector of nb_beeSolver objects. 
        bees                = [];
        
        % The reason for exiting. One of:
        % > 6  : Maximum number of solutions exceeded.
        % > 5  : User stop the optimization manually with finding of at 
        %        least the minimum number of solution asked for.
        % > 4  : Maximum time limit since last update exceeded 
        %        (maxTimeSinceUpdate) with finding of at least the 
        %        minimum number of solution asked for.
        % > 3  : Maximum time limit exceeded (maxTime) with finding of at 
        %        least the minimum number of solution asked for.
        % > 2  : Maximum iteration limit exceeded (maxIter) with finding  
        %        of at least the minimum number of solution asked for.
        % > 1  : Maximum function evaluation limit exceeded (maxFunEvals)
        %        with finding of at least the minimum number of solution 
        %        asked for.
        % > -1 : Maximum function evaluation limit exceeded (maxFunEvals)
        %        without finding the minimum number of solution
        %        asked for.
        % > -2 : Maximum iteration limit exceeded (maxIter) without 
        %        finding the minimum number of solution asked for.
        % > -3 : Maximum time limit exceeded (maxTime) without finding 
        %        the minimum number of solution asked for.
        % > -4 : Maximum time limit since last update exceeded 
        %        (maxTimeSinceUpdate) without finding the minimum number 
        %        of solution asked for.
        % > -5 : User stop the optimization manually without finding 
        %        the minimum number of solution asked for.
        exitFlag            = [];
        
        % Number of function evaluations.
        funEvals            = 0;
        
        % Number of iteration of the abc algorithm.
        iterations          = 0;
        
        % The merit function value of the solutions found.
        meritFunctionValue  = inf; 
        
        % The value of F(minXValue). As a N x 1 double. 
        minFFunctionValue
        
        % The minimized merit function value found during the solving. As  
        % a 1 x nSolutions double. 
        minFunctionValue    = inf;
        
        % The x values at the located minimum of the merit function. As a  
        % N x 1 double.
        minXValue           = [];
        
        % Number of solutions found (N).
        numSolutions        = 0;
        
        % The suggested solution of x. As a N x nSolutions double.
        xValue              = [];
        
    end
    
    properties (Access=private)
       
        % Time of last update in second.
        timeOfLastUpdate
        
        % Timer object used to measure the time spent.
        timer               = [];
        
    end
    
    methods
        
        function obj = nb_abcSolve(fh,init,lb,ub,options,varargin)
            
            if nargin < 1
                return
            end
            
            if nb_isOneLineChar(fh)
                fh = str2func(fh);
            elseif ~isa(fh,'function_handle')
                error([mfilename ':: The fh input must be a function handle or a string with the name of the function to minimize.'])
            end
            if isempty(varargin)
                obj.F = fh;
            else
                obj.F = @(x)nb_abcSolve.wrapper(x,fh,varargin);
            end
            
            if nargin > 1
                obj.initialXValue = init;
            end
            if nargin > 2
                obj.lowerBound = lb;
            end
            if nargin > 3
                obj.upperBound = ub;
            end
            if nargin > 4
                obj.options = options;
            end
            
        end
        
        function propertyValue = get.cutLimit(obj)
            propertyValue = obj.options.cutLimit;
        end
        
        function propertyValue = get.display(obj)
            propertyValue = obj.options.display;
        end
        
        function propertyValue = get.displayer(obj)
            propertyValue = obj.options.displayer;
        end
        
        function propertyValue = get.employedShare(obj)
            propertyValue = obj.options.employedShare;
        end
        
        function propertyValue = get.fitnessFunc(obj)
            propertyValue = obj.options.fitnessFunc;
        end
        
        function propertyValue = get.fitnessScale(obj)
            propertyValue = obj.options.fitnessScale;
        end
        
        function propertyValue = get.jacobianFunction(obj)
            propertyValue = obj.options.jacobianFunction;
        end
        
        function propertyValue = get.local(obj)
            propertyValue = obj.options.local;
        end 
        
        function propertyValue = get.maxFunEvals(obj)
            propertyValue = obj.options.maxFunEvals;
        end
        
        function propertyValue = get.maxIter(obj)
            propertyValue = obj.options.maxIter;
        end
        
        function propertyValue = get.maxNodes(obj)
            propertyValue = obj.options.maxNodes;
        end
        
        function propertyValue = get.maxSolutions(obj)
            propertyValue = obj.options.maxSolutions;
        end
        
        function propertyValue = get.maxTime(obj)
            propertyValue = obj.options.maxTime;
        end
        
        function propertyValue = get.maxTimeSinceUpdate(obj)
            propertyValue = obj.options.maxTimeSinceUpdate;
        end
        
        function propertyValue = get.maxTrials(obj)
            propertyValue = obj.options.maxTrials;
        end
        
        function propertyValue = get.meritFunction(obj)
            propertyValue = obj.options.meritFunction;
        end
        
        function propertyValue = get.minSolutions(obj)
            propertyValue = obj.options.minSolutions;
        end
        
        function propertyValue = get.newtonShare(obj)
            propertyValue = obj.options.newtonShare;
        end
        
        function propertyValue = get.newtonStop(obj)
            propertyValue = obj.options.newtonStop;
        end
        
        function propertyValue = get.objectiveLimit(obj)
            propertyValue = obj.options.objectiveLimit;
        end
        
        function propertyValue = get.numWorkers(obj)
            propertyValue = obj.options.numWorkers;
        end
        
        function propertyValue = get.tolerance(obj)
            propertyValue = obj.options.tolerance;
        end
        
        function propertyValue = get.toleranceX(obj)
            propertyValue = obj.options.toleranceX;
        end
        
        function propertyValue = get.useParallel(obj)
            propertyValue = obj.options.useParallel;
        end
        
        function set.cutLimit(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.cutLimit = 20;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 4
                error([mfilename ':: The value assign to cutLimit must be a positive scalar integer greater than 3.'])
            end
            obj.options.cutLimit = propertyValue;
              
        end
        
        function set.display(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.display = 'default';
                return
            end
            
            if ~(isa(propertyValue,'function_handle') || ischar(propertyValue))
                error([mfilename ':: The value assign to the display must be a char or a function handle.'])
            end
            obj.options.display = propertyValue;
              
        end
        
        function set.displayer(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.displayer = nb_optimizerDisplayer('storeMax',2,'notifyStep',10);
                return
            end
            
            if ~isa(propertyValue,'nb_optimizerDisplayer')
                error([mfilename ':: The value assign to the displayer must be a nb_optimizerDisplayer object.'])
            end
            obj.options.displayer = propertyValue;
              
        end
        
        function set.employedShare(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.employedShare = 0.33;
                return
            end
            
            if ~nb_isScalarNumber(propertyValue) || propertyValue <= 0.1 || propertyValue >= 0.9
                error([mfilename ':: The value assign to employedShare must be a scalar number between 0.1 and 0.9.'])
            end
            obj.options.employedShare = propertyValue;
              
        end
        
        function set.F(obj,propertyValue)
           
            if isempty(propertyValue)
                error([mfilename ':: You cannot set F to empty!'])
            end
            
            if ~isa(propertyValue,'function_handle')
                error([mfilename ':: The value assign to the F must be a function handle.'])
            end
            obj.F = propertyValue;
              
        end
        
        function set.fitnessFunc(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.fitnessFunc = @nb_fitness.standard;
                return
            end
            
            if ~isa(propertyValue,'function_handle')
                error([mfilename ':: The value assign to fitnessFunc must be a function handle.'])
            end
            obj.options.fitnessFunc = propertyValue;
              
        end
        
        function set.fitnessScale(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.fitnessScale = true;
                return
            end
            
            if ~nb_isScalarNumber(propertyValue)
                error([mfilename ':: The value assign to fitnessScale must be a scalar number.'])
            end
            obj.options.fitnessScale = propertyValue;
              
        end
        
        function set.initialXValue(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.initialXValue = 0;
                return
            end
            
            if ~isnumeric(propertyValue) || size(propertyValue,2) ~= 1
                error([mfilename ':: The value assign to the initialXValue must be a column vector of doubles.'])
            end
            obj.initialXValue = propertyValue;
              
        end
        
        function set.jacobianFunction(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.jacobianFunction = [];
                return
            end
            
            if ~isa(propertyValue,'function_handle')
                error([mfilename ':: The value assign to jacobianFunction must be a function handle.'])
            end
            obj.options.jacobianFunction = propertyValue;
              
        end
        
        function set.local(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.local = true;
                return
            end
            
            if ~nb_isScalarLogical(propertyValue)
                error([mfilename ':: The value assign to local must be a scalar logical.'])
            end
            obj.options.local = propertyValue;
              
        end
        
        function set.lowerBound(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.lowerBound = propertyValue;
                return
            end
            
            if ~isnumeric(propertyValue) || size(propertyValue,2) ~= 1
                error([mfilename ':: The value assign to the lowerBound must be a column vector of doubles.'])
            end
            obj.lowerBound = propertyValue;
              
        end
        
        function set.maxFunEvals(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxFunEvals = inf;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to maxFunEvals must be a positive scalar integer.'])
            end
            obj.options.maxFunEvals = propertyValue;
              
        end
        
        function set.maxIter(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxIter = inf;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to maxIter must be a positive scalar integer.'])
            end
            obj.options.maxIter = propertyValue;
              
        end
        
        function set.maxNodes(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxNodes = 20;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to maxNodes must be a positive scalar integer.'])
            end
            obj.options.maxNodes = propertyValue;
              
        end
        
        function set.maxSolutions(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxSolutions = inf;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue,0)
                error([mfilename ':: The value assign to maxSolutions must be a positive scalar integer.'])
            end
            obj.options.maxSolutions = propertyValue;
              
        end
        
        function set.maxTime(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxTime = 60*4;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to maxTime must be a positive scalar integer.'])
            end
            obj.options.maxTime = propertyValue;
              
        end
        
        function set.maxTimeSinceUpdate(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxTimeSinceUpdate = inf;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to maxTimeSinceUpdate must be a positive scalar integer.'])
            end
            obj.options.maxTimeSinceUpdate = propertyValue;
              
        end
        
        function set.maxTrials(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxTrials = 100;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to maxTrials must be a positive scalar integer.'])
            end
            obj.options.maxTrials = propertyValue;
              
        end
        
        function set.meritFunction(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.meritFunc = @(x)norm(x,2);
                return
            end
            
            if ~isa(propertyValue,'function_handle')
                error([mfilename ':: The value assign to meritFunc must be a function handle.'])
            end
            obj.options.meritFunc = propertyValue;
              
        end
        
        function set.minSolutions(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.minSolutions = inf;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue,0)
                error([mfilename ':: The value assign to minSolutions must be a positive scalar integer.'])
            end
            obj.options.minSolutions = propertyValue;
              
        end
        
        function set.newtonShare(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.newtonShare = 0.1;
                return
            end
            
            if ~nb_isScalarNumber(propertyValue) || propertyValue <= 0 || propertyValue >= 1
                error([mfilename ':: The value assign to newtonShare must be a scalar number between 0.1 and 0.9.'])
            end
            obj.options.newtonShare = propertyValue;
              
        end
        
        function set.newtonStop(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.newtonStop = false;
                return
            end
            
            if ~nb_isScalarLogical(propertyValue)
                error([mfilename ':: The value assign to newtonStop must be a scalar logical.'])
            end
            obj.options.newtonStop = propertyValue;
              
        end
        
        function set.objectiveLimit(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.objectiveLimit = 1e9;
                return
            end
            
            if ~nb_isScalarNumber(propertyValue)
                error([mfilename ':: The value assign to objectiveLimit must be a number.'])
            end
            obj.options.objectiveLimit = propertyValue;
              
        end
        
        function set.numWorkers(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.numWorkers = [];
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to numWorkers must be a positive scalar integer.'])
            end
            obj.options.numWorkers = propertyValue;
              
        end
        
        function set.options(obj,propertyValue)
           
            if nb_isempty(propertyValue)
                obj.options = nb_abcSolve.optimset(); % Default settings
                return
            end
            
            if ~isstruct(propertyValue)
                error([mfilename ':: The value assign to the options must be a struct. For more see the nb_fmin.optimset.'])
            end
            
            % Update options struct, while keeping defaults
            opt       = obj.options;
            fields    = fieldnames(opt);
            newFields = fieldnames(propertyValue);
            for ii = 1:length(newFields)
                ind = strcmpi(newFields{ii},fields);
                if sum(ind) == 0
                    continue
                elseif sum(ind) > 1
                    ind = find(ind);
                    ind = ind(end);
                end
                opt.(fields{ind}) = propertyValue.(newFields{ii});
            end
            obj.options = opt;
              
        end
        
        function set.tolerance(obj,propertyValue)
           
            if isempty(propertyValue)
                error([mfilename ':: You cannot set tolerance to empty!'])
            end
            
            if ~nb_isScalarNumber(propertyValue,0)
                error([mfilename ':: The value assign to the tolerance must be a scalar double.'])
            end
            obj.options.tolerance = propertyValue;
              
        end
        
        function set.toleranceX(obj,propertyValue)
           
            if isempty(propertyValue)
                error([mfilename ':: You cannot set tolerance to empty!'])
            end
            
            if ~nb_isScalarNumber(propertyValue,0)
                error([mfilename ':: The value assign to the toleranceX must be a scalar double.'])
            end
            obj.options.toleranceX = propertyValue;
              
        end
        
        function set.upperBound(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.upperBound = propertyValue;
                return
            end
            
            if ~isnumeric(propertyValue) || size(propertyValue,2) ~= 1
                error([mfilename ':: The value assign to the upperBound must be a column vector of doubles.'])
            end
            obj.upperBound = propertyValue;
              
        end
        
        function set.useParallel(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.useParallel = false;
                return
            end
            
            if not(ismember(propertyValue,[true,false]) && isscalar(propertyValue))
                error([mfilename ':: The value assign to useParallel must be eiter true or false.'])
            end
            obj.options.useParallel = propertyValue;
              
        end
        
    end
    
    methods (Access=private)
       
        function testOptions(obj)
        % Test the options before running the optimization
        
            [numX,col] = size(obj.initialXValue);
            if col > 1 && numX ~= 1
                error([mfilename ':: The initial values must be given as a vector.'])
            elseif col > 1 % Make it a column vector
                obj.initialXValue = obj.initialXValue(:);
                numX              = col;
            end
            
            if ~isempty(obj.lowerBound)
                obj.lowerBound = obj.lowerBound(:);
                if size(obj.lowerBound,1) ~= numX
                    error([mfilename ':: The lowerBound property (' int2str(size(obj.lowerBound,1)) ') does not match the '...
                                     'initialXValue property (' int2str(numX) ')'])
                end
                if any(~isfinite(obj.lowerBound))
                    error([mfilename ':: All elements of the lowerBound property must be finite!'])
                end  
            end
            if ~isempty(obj.upperBound)
                obj.upperBound = obj.upperBound(:);
                if size(obj.upperBound,1) ~= numX
                    error([mfilename ':: The upperBound property (' int2str(size(obj.upperBound,1)) ') does not match the '...
                                     'initialXValue property (' int2str(numX) ')'])
                end
                if any(~isfinite(obj.upperBound))
                    error([mfilename ':: All elements of the upperBound property must be finite!'])
                end 
            end
            
            if isempty(obj.upperBound) || isempty(obj.lowerBound)
                if isempty(obj.upperBound)
                    obj.upperBound = inf(numX,1);
                end
                if isempty(obj.lowerBound)
                    obj.lowerBound = -inf(numX,1);
                end
            else
                if any(obj.upperBound <= obj.lowerBound)
                    error([mfilename ':: Some of the upper bounds are lower than or equal to the lower bounds!'])
                end
            end
            
            if any(~isfinite(obj.upperBound) | ~isfinite(obj.lowerBound))
                if ~obj.local
                    warning([mfilename ':: lower and upper bounds are not given to ',...
                            'all values to solve for. Setting the local property to true. ',...
                            'Call help on the nb_abcSolver.local for more information. Will ',...
                            'only look for one solution.'])
                    obj.local        = true;
                    obj.maxSolutions = 1;
                    obj.minSolutions = 1;
                end
            end
            
            try
                fVal = obj.F(obj.initialXValue);
            catch
                error([mfilename ':: Could not evaluate the provided function at the inital value.'])
            end
            if size(fVal,1) ~= numX || size(fVal,2) > 1
                error([mfilename ':: The function to solve must return a ' int2str(numX) 'x1 double, ',...
                      'is ' int2str(size(fVal,1)) 'x1.'])
            end
            
        end
        
        function initialize(obj)
            
            % Initialize the bees. I.e. here all bees will be scouting
            % for a new location to feed
            obj.bees                = nb_beeSolver(obj.maxNodes);
            numEmp                  = ceil(obj.employedShare*obj.maxNodes);
            [obj.bees(1:numEmp),fc] = initialize(obj.bees(1:numEmp),obj.F,obj.meritFunction,obj.initialXValue,...
                                                 obj.lowerBound,obj.upperBound,obj.objectiveLimit,...
                                                 obj.maxTrials,obj.local,obj.newtonShare);
            obj.funEvals = fc;
            updateStatus(obj);
            obj.bees(1:numEmp) = calcFitness(obj.bees(1:numEmp),obj.fitnessFunc,obj.minFunctionValue,obj.fitnessScale);
            reportStatus(obj); 
            
            % Give the onlooker bees the trivial solution to start with
            obj.bees(numEmp+1:end) = dealZeros(obj.bees(numEmp+1:end),size(obj.bees(1).current,1));
            
        end
        
        function doSolving(obj)
            
            obj.timer            = tic();
            obj.timeOfLastUpdate = 0;
            while check(obj)
            
                obj.bees = relocate(obj.bees,obj.lowerBound,obj.upperBound,obj.cutLimit,...
                                    obj.local,obj.F,obj.jacobianFunction,obj.tolerance,...
                                    obj.newtonStop,obj.minXValue,obj.minFunctionValue,...
                                    obj.minFFunctionValue);
                if obj.useParallel
                    obj.bees = evaluateParallel(obj.bees,obj.F,obj.meritFunction);
                else
                    obj.bees = evaluate(obj.bees,obj.F,obj.meritFunction);
                end
                obj.funEvals   = obj.funEvals + obj.maxNodes;
                obj.iterations = obj.iterations + 1;
                obj.bees       = updateLocation(obj.bees);
                updateStatus(obj);
                obj.bees       = calcFitness(obj.bees,obj.fitnessFunc,obj.minFunctionValue,obj.fitnessScale);
                reportStatus(obj);
                
            end
            
            reportDone(obj);
        
        end
        
        function status = check(obj)
        % Check if some limits has been breached
        
            status = true;
            if obj.maxFunEvals <= obj.funEvals
                if obj.numSolutions < obj.minSolutions
                    obj.exitFlag = -1;
                else
                    obj.exitFlag = 1;
                end
                status = false;
            end
            if obj.maxIter <= obj.iterations
                if obj.numSolutions < obj.minSolutions
                    obj.exitFlag = -2;
                else
                    obj.exitFlag = 2;
                end
                status = false;
            end
            if obj.maxTime <= toc(obj.timer)
                if obj.numSolutions < obj.minSolutions
                    obj.exitFlag = -3;
                else
                    obj.exitFlag = 3;
                end
                status = false;
            end
            if obj.maxTimeSinceUpdate <= (toc(obj.timer) - obj.timeOfLastUpdate)
                if obj.numSolutions < obj.minSolutions
                    obj.exitFlag = -4;
                else
                    obj.exitFlag = 4;
                end
                status = false;
            end
            if obj.options.displayer.stopped
                if obj.numSolutions < obj.minSolutions
                    obj.exitFlag = -5;
                else
                    obj.exitFlag = 5;
                end
                status = false;
            end
            if obj.maxSolutions <= obj.numSolutions
                obj.exitFlag = 6;
                status       = false;
            end
            
        end
        
        function updateStatus(obj)
        % Update the global solution candidates until now
        
            fValBees = [obj.bees.currentValue];
            ind      = fValBees < obj.tolerance;
            if any(ind)
                % Locate the new solutions, and remove already found ones
                loc  = find(ind);
                for ii = loc
                    if isempty(obj.xValue)
                        obj.xValue             = obj.bees(ii).current;
                        obj.meritFunctionValue = fValBees(ii);
                        obj.minXValue          = obj.bees(ii).current;
                        obj.minFunctionValue   = fValBees(ii);
                        obj.minFFunctionValue  = obj.bees(ii).currentFValue;
                        obj.numSolutions       = obj.numSolutions + 1;
                    else
                        new = false(1,size(obj.xValue,2));
                        for jj = 1:size(obj.xValue,2)
                            if obj.meritFunction(obj.xValue(:,jj) - obj.bees(ii).current) > obj.toleranceX
                                new(jj) = true;
                            end
                        end
                        if all(new)
                            % Found a new solution, so append it
                            obj.meritFunctionValue = [obj.meritFunctionValue,fValBees(ii)];
                            obj.xValue             = [obj.xValue,obj.bees(ii).current]; 
                            obj.minXValue          = obj.bees(ii).current;
                            obj.minFunctionValue   = fValBees(ii);
                            obj.minFFunctionValue  = obj.bees(ii).currentFValue;
                            obj.numSolutions       = obj.numSolutions + 1;
                            if ~isempty(obj.timer)
                                obj.timeOfLastUpdate = toc(obj.timer);
                            end
                        end
                        
                    end
                end
                
            else
                [fMinBees,ind] = min([obj.bees.currentValue]);
                if fMinBees < obj.minFunctionValue
                    obj.minFunctionValue  = fMinBees;
                    obj.minXValue         = obj.bees(ind).current;
                    obj.minFFunctionValue = obj.bees(ind).currentFValue;
                    if ~isempty(obj.timer)
                        obj.timeOfLastUpdate = toc(obj.timer);
                    end
                end
            end
            
        end
        
        function reportStatus(obj)
        % Call the update method on the nb_optimizerDisplayer to report 
        % results to user.
            resForDisplay = struct('iteration',obj.iterations,'fval',obj.minFunctionValue);
            update(obj.displayer,obj.numSolutions,resForDisplay,'iter');
        end
        
        function reportDone(obj)
        % Call the update method on the nb_optimizerDisplayer to report 
        % results to user.
            resForDisplay            = struct('iteration',obj.iterations,'fval',obj.minFunctionValue);
            quitMessage              = nb_wrapped(nb_abcSolve.interpretExitFalg(obj.exitFlag),60);
            quitMessage              = strcat(quitMessage,'\n')';
            quitMessage              = horzcat(quitMessage{:});
            oldFormat                = obj.displayer.formatDone;
            obj.displayer.formatDone = [quitMessage,'\n',oldFormat]; 
            update(obj.displayer,obj.numSolutions,resForDisplay,'done');
            
            % Handle, so must reset, or else it will remmeber this for
            % later
            obj.displayer.formatDone = oldFormat; 
        end
            
    end
    
    methods (Static=true)
        function value = wrapper(x,fHandle,inputs)
           value = fHandle(x,inputs{:}); 
        end
        function message = interpretExitFalg(e)
            
            switch e
                case 6
                    message = 'Maximum number of solutions exceeded.';
                case 5
                    message = ['User stop the optimization manually with finding of at least the ',...
                               'minimum number of solution asked for.'];
                case 4
                    message = ['Maximum time limit since last update exceeded with finding of ',...
                               'at least the minimum number of solution asked for.'];
                case 3
                    message = ['Maximum time limit exceeded with finding of at least the minimum ',...
                               'number of solution asked for.'];
                case 2
                    message = ['Maximum number of iterations exceeded with finding of at least ',...
                               'the minimum number of solution asked for.'];
                case 1
                    message = ['Maximum function evaluation limit exceeded with finding of at ',...
                               'least the minimum number of solution asked for.'];
                case -1
                    message = ['Error during nb_abcSolve:: Maximum function evaluation limit ',...
                               'exceeded without finding the minimum number of solution',...
                               'asked for.'];
                case -2
                    message = ['Error during nb_abcSolve:: Maximum number of iterations ',...
                               'exceeded without finding the minimum number of solution ',...
                               'asked for.'];
                case -3
                    message = ['Error during nb_abcSolve:: Maximum time limit exceeded ',...
                               'without finding the minimum number of solution asked for.'];
                case -4
                    message = ['Error during nb_abcSolve:: Maximum time limit since last update ',...
                               'exceeded without finding the minimum number of solution ',...
                               'asked for.'];
                case -5
                    message = ['Error during nb_abcSolve:: User stop the optimization manually ',...
                               'without finding the minimum number of solution asked for.'];
                otherwise
                    message = '';
            end

        end
    end
    
    methods (Static=true)
        varargout = call(varargin);
        varargout = optimset(varargin);
        varargout = test(varargin);
        varargout = test2(varargin);
        varargout = test2local(varargin);
        varargout = test3(varargin);
        varargout = testParallel(varargin); 
    end
    
end

