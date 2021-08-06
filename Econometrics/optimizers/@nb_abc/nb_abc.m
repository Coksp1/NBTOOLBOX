classdef nb_abc < handle
% Description:
%
% An implimentation of the artificial bee colony algorithm by Karaboga.
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
% min     Q(x)
% x in S
%
% Or the constrained problem
%
% min     Q(x)
% x in S
%
% s.t. x in F
%
% Where Q is the objective to minimize and x is the inputs to the
% objective. S is the search space, i.e. the space to look for candidate
% values that minimizes the objective Q. F is the feasible space, and can
% be provided by using the constraints property. You can apply both
% inequality constraints g(x) <= 0 or equality constraints h(x) == 0. In
% the latter case you will apply the inequality constraints 
% abs(h(x)) - tolerance <= 0, where tolerance is a small number. It can be
% set using the field tolerance of the options struct.
%
% Caution: The steps of this implementation is slightly different from that
%          of Karaboga et. al (2012).
%
%          Initialize employed bees by scouting.
%
%          Repeat:
%
%          1. Employed bees that has reached the cutLimit are sent out
%             scouting. See nb_bee.scout.
%          2. Send onlookers to join the employed bees by random. Higher
%             probabilities are assign to the employed bees that  
%             communicates good values of the objective. Finally onlookers  
%             are sent to explore the neighbourhood of the selected 
%             employed bee by changing the value of one parameter, which 
%             is selected at random. See nb_bee.joinDance. The
%             probabilities are calculated accordingly to Stanarevic et. 
%             al (2015) in the case of constrained minimization.
%          3. Employed bees are then sent to explore their neighbourhood 
%             by changing the value of one parameter, which is selected at 
%             random. See nb_bee.dance.
%          4. All the new points of the bees are evaluated. (This is the
%             step that can be ran in parallel.)
%          5. The best point in the parameter space is saved.
%
%          This is repeated until some of the limits (maxTime, maxFunEvals,
%          maxIter or maxTimeSinceUpdate are reached).
%
% Superclasses:
%
% handle
%
% Constructor:
%
%   obj = nb_abc(fh,init,lb,ub)
%   obj = nb_abc(fh,init,lb,ub,options,varargin)   
% 
%   Input:
%
%   - fh       : See the dcumentation of the objective property of the 
%                nb_abc class. 
%
%   - init     : See the dcumentation of the initialXValue property of the 
%                nb_abc class.
%
%   - lb       : See the dcumentation of the lowerBound property of the 
%                nb_abc class.
%
%   - ub       : See the dcumentation of the upperBound property of the 
%                nb_abc class.
%
%   - options  : See the nb_abc.optimset method for more on this input.
% 
%   Optional inputs:
%
%   - varargin : Optional number of inputs given to the objective when 
%                it is called during the minimization algorithm.
%
%   Output:
% 
%   - obj : An object of class nb_abc.
% 
% See also: 
% nb_abc.optimset, nb_abc.call, nb_fmin, fmincon, fminunc, fminsearch, 
% bee_gate (RISE toolbox) 
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
        
        % Set to false to not calculate the Hessian at the found minimum.
        % If true the Hessian will be calculated using the nb_hessian
        % function. Default is true
        doHessian
        
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
        
        % Positive integer. Maximum number of function evaluation allowed. 
        % Default is inf.
        maxFunEvals
        
        % Positive integer. Maximum number of iterations allowed. Default 
        % is inf.
        maxIter
        
        % Positive integer. The number of bees to use during optimization. 
        maxNodes
        
        % Positive integer. The maximum time spent on optimization in 
        % seconds.
        maxTime
        
        % Positive integer. The maximum time spent on optimization since
        % last time the minimum point where updated (in seconds).
        maxTimeSinceUpdate
        
        % Positive integer. The maximum trial that is allowed for finding
        % initial candidates. Default is 100.
        maxTrials
        
        % Positive integer. Number of worker to use when running 
        % optimization in parallel.
        numWorkers
        
        % Double. If the objective return a value greater than this, a new
        % candidate of x is drawn. Default is 1e9.
        objectiveLimit
        
        % Name of the file to save the object, with path, but without
        % extension.
        saveName
        
        % The time between saving of the object.
        saveTime
        
        % Tolerance value used for equality constraint optimization
        % problems.
        tolerance
        
        % true or false. Give true if the nodes should be spread on 
        % different parallel workers.
        useParallel
        
    end
    
    properties (Dependent=true,SetAccess=protected)
       
        % true if minimization is constrained, otherwise false. See
        % constraints property.
        hasConstraints  
        
    end
        
    properties
       
        % A function handle that applies the linear or non-linear
        % constrainst on the parameters. If not given, or given as [], 
        % unconstrained minimization will be done.
        %
        % It must return two outputs. The first output must be a vector
        % with the values of the inequality constraints g(x) <= 0. Positive
        % numbers means violation. The second input must return a vector
        % with the values of the equality constraints h(x) == 0. If
        % abs(h(x)) > options.tolerance means a violation.
        %
        % Example: 
        %
        % function [c,ceq] = conFunc(x,a)
        %   c   = a*x(1) - x(2); % inequality constraint a*x(1) - x(2) <= 0
        %   ceq = x(3) - x(2);   % equality constraint x(3) - x(2) == 0
        % end
        constraints         = [];
        
        % The initial values of the optimization. Default is zero. As a 
        % N x 1 double.
        initialXValue       = 0;
        
        % The lower bound on the x values. As a N x 1 double. Must be
        % finite!
        lowerBound          = [];
        
        % The objective to minimize. As a function handle. Must take
        % a N x 1 double as the first input.
        objective           = [];
        
        % A struct with the options of the optimiziation. See the
        % nb_abc.optimset method for more on this option.
        options             = nb_abc.optimset();
        
        % The upper bound on the x values. As a n x 1 double. Must be
        % finite!
        upperBound          = [];
        
    end
    
    properties (SetAccess = protected)
        
        % A vector of nb_bee objects. 
        bees                = [];
        
        % The reason for exiting. One of:
        %
        % > 0  : Maximum function evaluation limit exceeded (maxFunEvals).
        % > -1 : Maximum iteration limit exceeded (maxIter).
        % > -2 : Maximum time limit exceeded (maxTime).
        % > -3 : Maximum time limit since last update exceeded 
        %        (maxTimeSinceUpdate).
        % > -4 : User stop the optimization manually.
        exitFlag            = [];
        
        % Number of function evaluations.
        funEvals            = 0;
        
        % Number of iteration of the abc algorithm.
        iterations          = 0;
        
        % The minimized value found during the optimization. As a scalar
        % double.
        minFunctionValue    = inf; 
        
        % The x values at the located minimum. As a nVar x 1 double.
        minXValue           = [];
        
        % A nVar x nVar double with the estimated Hessian at the found
        % minimum.
        hessian             = [];
        
    end
    
    properties (Access=private)
       
        % Time of last update in second.
        timeOfLastUpdate
        
        % Time of last save of object, in second.
        timeOfLastSave
        
        % Timer object used to measure the time spent.
        timer               = [];
        
    end
    
    methods
        
        function obj = nb_abc(fh,init,lb,ub,options,constraints,varargin)
            
            if nargin < 1
                return
            end
            
            if nb_isOneLineChar(fh)
                fh = str2func(fh);
            elseif ~isa(fh,'function_handle')
                error([mfilename ':: The fh input must be a function handle or a string with the name of the function to minimize.'])
            end
            if isempty(varargin)
                obj.objective = fh;
            else
                obj.objective = @(x)nb_abc.wrapper(x,fh,varargin);
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
            if nargin > 5
                obj.constraints = constraints;
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
        
        function propertyValue = get.doHessian(obj)
            propertyValue = obj.options.doHessian;
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
        
        function propertyValue = get.hasConstraints(obj)
            propertyValue = ~isempty(obj.constraints);
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
        
        function propertyValue = get.maxTime(obj)
            propertyValue = obj.options.maxTime;
        end
        
        function propertyValue = get.maxTimeSinceUpdate(obj)
            propertyValue = obj.options.maxTimeSinceUpdate;
        end
        
        function propertyValue = get.maxTrials(obj)
            propertyValue = obj.options.maxTrials;
        end
        
        function propertyValue = get.objectiveLimit(obj)
            propertyValue = obj.options.objectiveLimit;
        end
        
        function propertyValue = get.numWorkers(obj)
            propertyValue = obj.options.numWorkers;
        end
        
        function propertyValue = get.saveName(obj)
            propertyValue = obj.options.saveName;
        end
        
        function propertyValue = get.saveTime(obj)
            propertyValue = obj.options.saveTime;
        end
        
        function propertyValue = get.tolerance(obj)
            propertyValue = obj.options.tolerance;
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
        
        function set.doHessian(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.doHessian = true;
                return
            end
            
            if ~nb_isScalarLogical(propertyValue)
                error([mfilename ':: The value assign to doHessian must be a scalar logical.'])
            end
            obj.options.doHessian = propertyValue;
              
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
        
        function set.lowerBound(obj,propertyValue)
           
            if isempty(propertyValue)
                error([mfilename ':: You cannot set lowerBound to empty!'])
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
        
        function set.maxTime(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxTime = 60*4;
                return
            end
            
            if ~nb_isScalarPositiveNumber(propertyValue)
                error([mfilename ':: The value assign to maxTime must be a positive scalar number.'])
            end
            obj.options.maxTime = propertyValue;
              
        end
        
        function set.maxTimeSinceUpdate(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxTimeSinceUpdate = inf;
                return
            end
            
            if ~nb_isScalarPositiveNumber(propertyValue)
                error([mfilename ':: The value assign to maxTimeSinceUpdate must be a positive scalar number.'])
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
        
        function set.objective(obj,propertyValue)
           
            if isempty(propertyValue)
                error([mfilename ':: You cannot set objective to empty!'])
            end
            
            if ~isa(propertyValue,'function_handle')
                error([mfilename ':: The value assign to the objective must be a function handle.'])
            end
            obj.objective = propertyValue;
              
        end
        
        function set.options(obj,propertyValue)
           
            if nb_isempty(propertyValue)
                obj.options = nb_abc.optimset(); % Default settings
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
        
        function set.saveName(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.saveName = '';
                return
            end
            
            if ~nb_isOneLineChar(propertyValue)
                error([mfilename ':: The value assign to saveName must be a one line char.'])
            end
            [pathstr, name] = fileparts(propertyValue);
            if isempty(name)
                error('saveName is not a proper file.')
            end
            if isempty(pathstr)
                propertyValue = name;
            else
                propertyValue = [pathstr, filesep, name];
            end
            obj.options.saveName = propertyValue;
              
        end
        
        function set.saveTime(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.saveTime = inf;
                return
            end
            
            if ~nb_isScalarPositiveNumber(propertyValue)
                error([mfilename ':: The value assign to saveTime must be a positive scalar number.'])
            end
            obj.options.saveTime = propertyValue;
              
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
        
        function set.upperBound(obj,propertyValue)
           
            if isempty(propertyValue)
                error([mfilename ':: You cannot set upperBound to empty!'])
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
            
            if isempty(obj.lowerBound)
                error([mfilename ':: The lowerBound property cannot be empty!'])
            else
                obj.lowerBound = obj.lowerBound(:);
                if size(obj.lowerBound,1) ~= numX
                    error([mfilename ':: The lowerBound property (' int2str(size(obj.lowerBound,1)) ') does not match the '...
                                     'initialXValue property (' int2str(numX) ')'])
                end
                if any(~isfinite(obj.lowerBound))
                    error([mfilename ':: All elements of the lowerBound property must be finite!'])
                end  
            end
            if isempty(obj.upperBound)
                error([mfilename ':: The upperBound property cannot be empty!'])
            else
                obj.upperBound = obj.upperBound(:);
                if size(obj.upperBound,1) ~= numX
                    error([mfilename ':: The upperBound property (' int2str(size(obj.upperBound,1)) ') does not match the '...
                                     'initialXValue property (' int2str(numX) ')'])
                end
                if any(~isfinite(obj.upperBound))
                    error([mfilename ':: All elements of the upperBound property must be finite!'])
                end 
            end
            
            if any(obj.upperBound <= obj.lowerBound)
                error([mfilename ':: Some of the upper bounds are lower than or equal to the lower bounds!'])
            end
            
        end
        
        varargout = initialize(varargin);
        varargout = doMinimization(varargin);
        varargout = getConstraints(varargin);
        varargout = check(varargin);
        varargout = updateStatus(varargin);
        varargout = reportStatus(varargin);
           
    end
    
    methods (Static=true)
        function value = wrapper(x,fHandle,inputs)
           value = fHandle(x,inputs{:}); 
        end
        function c = combineConstraints(x,constraints,tolerance)
            [c,ceq] = constraints(x); 
            if ~isempty(ceq)
                ceq = abs(ceq) - tolerance;
                c   = [c(:);ceq(:)];
            else
                c = c(:);
            end
        end
    end
    
    methods (Static=true)
        varargout = call(varargin);
        varargout = optimset(varargin);
        varargout = test(varargin);
        varargout = testConstrained(varargin);
        varargout = testParallel(varargin); 
        varargout = testSave(varargin);
    end
    
end

