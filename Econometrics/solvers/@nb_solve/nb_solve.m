classdef nb_solve < nb_settable & nb_getable
% Description:
%
% A class for solving non-linear problems on the form
%
% F(x) = 0
%
% Constructor:
%
%   obj = nb_solve(fh,init)
%   obj = nb_solve(F,init,options,JF,varargin)
% 
%   Input:
%
%   - F        : See the dcumentation of the F property of the nb_solve 
%                class. Must be given. 
%
%   - init     : See the dcumentation of the init property of the 
%                nb_solve class. Must be given.
%
%   - options  : See the nb_solve.optimset method for more on this input.
%                Can be empty.
%
%   - JF       : See the dcumentation of the JF property of the nb_solve 
%                class. Can be empty. 
% 
%   Optional inputs:
%
%   - varargin : Optional number of inputs given to the F (and JF)  
%                function(s) when it is called during the solution 
%                algorithm.
%   Output:
% 
%   - obj : An object of nb_solve
% 
%   Examples:
%
%   obj      = nb_solve(@(x)x^2,1);
%   [x,fVal] = nb_solve.call(@(x)x^2,1)
% 
% See also: 
% fsolve, nb_solve.call
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties
        
        % Reason for exiting the solving. A 1 means that the solver
        % succeeded, while a value less than 1 means it failed. See the
        % function nb_interpretExitFlag for how to interpret the exitFlag
        % property.
        exitFlag            = 1;
        
        % A function handle with the problem to solve. It is assumed 
        % to take a double with size M x 1 as input.
        F                   = [];
        
        % The number of function evaluations done during the solving of 
        % the problem.
        funEvals            = 0;
        
        % Function value at last iteration, as M x 1 double. If the solver 
        % converged it will have norm less than given by the tolerance 
        % property.
        fVal                = [];
        
        % The number of iterations done during the solving of the problem.
        iter                = 0;
        
        % Jacobian matrix at last iteration, as M x M double.
        jacobian            = [];
        
        % A function handle that return the jacobian of the problem to  
        % solve (F). It is assumed to take a double with size M x 1 as 
        % input. Only needed for the methods that uses derivative based 
        % methods.
        JF                  = [];
        
        % Intial values. A M x 1 double.
        initialXValue       = [];
        
        % Merit value of F(x). See meritFunction for the function applied. 
        % Default merit function is the first norm.
        meritFVal           = [];
        
        % Merit value of x(n) - x(n-1). See meritFunction for the function
        % applied. Default merit function is the first norm.
        meritXChange        = [];
        
        % Options of the solver selected. See the nb_solve.optimset method.
        % If given as empty (struct) default options will be used.
        options             = nb_solve.optimset();
        
        % Solution at last iteration, as a M x 1 double. If the solver
        % converged it will be the solution to the problem.
        x                   = [];
        
    end
    
    properties (Dependent=true) 
        
        % Select the method to use to update the spectral step length
        % when using the methods 'sane' or 'dfsane'. Choose amoung 1,2 or
        % 3. Default is 2. See the methods nb_solve.alphaMethod1, 
        % nb_solve.alphaMethod2 and nb_solve.alphaMethod3.
        alphaMethod
        
        % Convergence criteria to use. Either 'function' (default) or 
        % 'stepSize'. 'function' means that the criteria being used is 
        % the first norm of F(x), while 'stepSize' means that the first  
        % norm of the step size (x(n) - x(n-1)) is used. See the property 
        % tolerance for the convergence measure.
        criteria 
        
        % 'off' | 'iter' | 'final' | 'notify' Level of display. 'off' 
        % displays no output; 'iter' displays output at each iteration 
        % 'final' displays just the final output; ''notify'' displays 
        % output only if the function does not converge.
        display             
        
        % An object of class nb_optimizerDisplayer. This object set the way
        % the optimizer displayes result during the optimization.
        displayer   
         
        % Parameter used in the non-monotone line search step of the 
        % 'dfsane' and 'sane' methods.
        gamma
        
        % Positive integer. Set the number of periods that is remember in
        % the 'dfsane' and 'sane' method. Normal to have a value between
        % 5-20. Default is 10. High value will garanti a better
        % approximation.
        memory 
        
        % Positive integer. Maximum number of function evaluation allowed. 
        % Default is inf.
        maxFunEvals
        
        % Positive integer. Maximum number of iterations allowed. Default 
        % is 10000. 
        maxIter
        
        % Positive integer. Maximum number of iterations allowed between
        % effective update. Default is 500. Used for global algorithm only.
        maxIterSinceUpdate
        
        % Positive integer. The maximum time spent on optimization in 
        % seconds.
        maxTime
        
        % A function handle that specifies the merit function to use when
        % convergence is checked. Default is @(x)norm(x,1). The merit
        % function must map a M x 1 double into a scalar double. A number
        % close to 0 is taken as convergence.
        meritFunction 
        
        % Select the method to use to solve the problem. 
        % > 'newton'      : Uses a the Newton-Raphson method. The JF 
        %   property must be given in this case. 
        % > 'steffensen'  : Uses the Steffensen method. Where the
        %   derivative is numerically estimated.
        % > 'steffensen2' : Uses a two steps steffensen method. Where the
        %   derivative is numerically estimated.
        % > 'broyden'     : Uses the Broyden method. Where the derivative 
        %   is numerically updated at each iteration. Default method.
        % > 'sane'        : Uses the La Cruz and Raydan (2003) method.
        % > 'dfsane'      : Uses the  La Cruz, Mart´?nez, and Raydan
        %   (2006) method. Which is a derivativ free version of 'sane'.
        method
        
        % Positive integer. Number of worker to use when running 
        % optimization in parallel.
        numWorkers
        
        % Step length applied when calculating numerical first difference
        % objects. For example (F(x + h) - F(x))/h. h is here the selected
        % step length
        stepLength
        
        % Tolerance value for convergence. Default is 1e-7.
        tolerance
        
        % true or false. Give true if the nodes should be spread on 
        % different parallel workers.
        useParallel
        
    end
    
    properties (SetAccess=protected)
        
    end
    
    methods
        
        function obj = nb_solve(F,init,options,JF,varargin)
            if nargin == 0
                return
            end
            if nb_isOneLineChar(F)
                F = str2func(F);
            elseif ~isa(F,'function_handle')
                error([mfilename ':: The F input must be a function handle or a string with the name of the function to minimize.'])
            end
            if isempty(varargin)
                obj.F = F;
            else
                obj.F = @(x)nb_abc.wrapper(x,F,varargin);
            end
            if nargin > 1
                obj.initialXValue = init;
            end
            if nargin > 2
                obj.options = options;
            end
            if nargin > 3
                if ~isempty(JF)
                    if nb_isOneLineChar(JF)
                        JF = str2func(JF);
                    elseif ~isa(JF,'function_handle')
                        error([mfilename ':: The JF input must be a function handle or a string with the name of the function to minimize.'])
                    end
                    if isempty(varargin)
                        obj.JF = JF;
                    else
                        obj.JF = @(x)nb_abc.wrapper(x,JF,varargin);
                    end
                end
            end

        end
        
        function propertyValue = get.alphaMethod(obj)
            propertyValue = obj.options.alphaMethod;
        end
        
        function propertyValue = get.criteria(obj)
            propertyValue = obj.options.criteria;
        end
        
        function propertyValue = get.display(obj)
            propertyValue = obj.options.display;
        end
        
        function propertyValue = get.displayer(obj)
            propertyValue = obj.options.displayer;
        end
        
        function propertyValue = get.gamma(obj)
            propertyValue = obj.options.gamma;
        end

        function propertyValue = get.memory(obj)
            propertyValue = obj.options.memory;
        end
        
        function propertyValue = get.maxFunEvals(obj)
            propertyValue = obj.options.maxFunEvals;
        end
        
        function propertyValue = get.maxIter(obj)
            propertyValue = obj.options.maxIter;
        end

        function propertyValue = get.maxIterSinceUpdate(obj)
            propertyValue = obj.options.maxIterSinceUpdate;
        end
        
        function propertyValue = get.maxTime(obj)
            propertyValue = obj.options.maxTime;
        end
        
        function propertyValue = get.method(obj)
            propertyValue = obj.options.method;
        end
        
        function propertyValue = get.numWorkers(obj)
            propertyValue = obj.options.numWorkers;
        end
        
        function propertyValue = get.stepLength(obj)
            propertyValue = obj.options.stepLength;
        end
        
        function propertyValue = get.tolerance(obj)
            propertyValue = obj.options.tolerance;
        end
        
        function propertyValue = get.useParallel(obj)
            propertyValue = obj.options.useParallel;
        end
        
        function set.alphaMethod(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.alphaMethod = 2;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue,0)
                error([mfilename ':: The value assign to the alphaMethod must be a scalar integer larger then 0.'])
            end
            if ~ismember(propertyValue,[1,2,3])
                error([mfilename ':: The value assign to the alphaMethod must either be 1,2 or 3.'])
            end
            obj.options.alphaMethod = propertyValue;
              
        end
        
        function set.criteria(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.criteria = 'function';
                return
            end
            
            if ~ischar(propertyValue)
                error([mfilename ':: The value assign to the criteria must be a char.'])
            end
            if ~any(strcmpi(propertyValue,{'function','stepsize'}))
                error([mfilename ':: The value assign to the criteria cannot be ' propertyValue '.'])
            end
            obj.options.criteria = propertyValue;
              
        end
        
        function set.display(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.display = 'iter';
                return
            end
            
            if ~ischar(propertyValue)
                error([mfilename ':: The value assign to the display must be a char.'])
            end
            if ~any(strcmpi(propertyValue,{'iter','final','off','notify'}))
                error([mfilename ':: The value assign to the display cannot be ' propertyValue '.'])
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
        
        function set.F(obj,value)
            if isempty(value)
                error([mfilename ':: The F property (the problem) cannot be set to empty.'])
            end
            if ~isa(value,'function_handle')
                error([mfilename ':: F property (the problem) must be set to a function handle.'])
            end
            obj.F = value;
        end
        
        function set.gamma(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.gamma = 1e-4;
                return
            end
            
            if ~nb_isScalarNumber(propertyValue,0)
                error([mfilename ':: The value assign to the gamma must be a scalar strictly positive double.'])
            end
            obj.options.gamma = propertyValue;
              
        end
        
        function set.JF(obj,value)
            if ~isa(value,'function_handle')
                error([mfilename ':: The JF property (the function that return the ',...
                    'jacobian of the problem) must be set to a function handle.'])
            end
            obj.JF = value;
        end
        
        function set.initialXValue(obj,value)
            if isempty(value)
                error([mfilename ':: The initialXValue property (inital values) cannot be set to empty.'])
            end
            [N,C,P] = size(value);
            if C > 1
                if N > 1
                    error([mfilename ':: The initialXValue property must be set a vector.'])
                else 
                    value = value(:);
                end
            end
            if ~isnumeric(value)
                error([mfilename ':: The initialXValue property must be set to a double vector.'])
            end
            if P > 1
                error([mfilename ':: The initialXValue property cannot be set to a double with more pages.'])
            end
            obj.initialXValue = value;
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
                obj.options.maxIter = 10000;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue,0)
                error([mfilename ':: The value assign to maxIter must be a positive scalar integer.'])
            end
            obj.options.maxIter = propertyValue;
              
        end
        
        function set.maxIterSinceUpdate(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxIterSinceUpdate = 500;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue,0) 
                error([mfilename ':: The value assign to maxIterSinceUpdate must be a positive scalar integer.'])
            end
            obj.options.maxIterSinceUpdate = propertyValue;
              
        end
        
        function set.maxTime(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.maxTime = inf;
                return
            end
            
            if ~nb_isScalarInteger(propertyValue) || propertyValue < 1
                error([mfilename ':: The value assign to maxTime must be a positive scalar integer.'])
            end
            obj.options.maxTime = propertyValue;
              
        end
        
        function set.memory(obj,value)
            if isempty(value)
                obj.memory = 10;
                return
            end
            if ~nb_isScalarInteger(value,0)
                error([mfilename ':: M property must be set to a integer larger than 0.'])
            end
            obj.options.memory = value;
        end
        
        function set.method(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.method = 'broyden';
                return
            end
            
            if ~nb_isOneLineChar(propertyValue)
                error([mfilename ':: The value assign to method must be a one line char.'])
            end
            methods = nb_solve.getMethods();
            if ~any(strcmpi(propertyValue,methods))
                error([mfilename ':: The method ' propertyValue ' is not supported by the nb_solve class. See the method nb_solve.getMethods().'])
            end
            obj.options.method = propertyValue;
              
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
            if isempty(propertyValue)
                obj.options = nb_solve.optimset();
                return
            end
            if ~isstruct(propertyValue)
                error([mfilename ':: The options property must be set to a struct.'])
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
        
        function set.stepLength(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.stepLength = 1e-7;
                return
            end
            
            if ~nb_isScalarNumber(propertyValue,0)
                error([mfilename ':: The value assign to the stepLength must be a scalar strictly positive double.'])
            end
            obj.options.stepLength = propertyValue;
              
        end
        
        function set.tolerance(obj,propertyValue)
           
            if isempty(propertyValue)
                obj.options.tolerance = 1e-7;
                return
            end
            
            if ~nb_isScalarNumber(propertyValue,0)
                error([mfilename ':: The value assign to the tolerance must be a scalar strictly positive double.'])
            end
            obj.options.tolerance = propertyValue;
              
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
    
    methods (Access=protected)
       
        function update(obj) %#ok<MANU>
            % Empty function
        end
        
    end
    
    methods (Static=true)
        
        function reportStatus(displayer,iter,x,fval,state)
        % Call the update method on the nb_optimizerDisplayer to report 
        % results to user.
        
            resForDisplay = struct('iteration',iter,'fval',fval);
            if strcmp(state,'done')
               if rem(iter,displayer.notifyStep) == 0
                   update(displayer,x,resForDisplay,'iter');
               end
            end
            update(displayer,x,resForDisplay,state);
            
        end
        
        function reportError(displayer,exitFlag)
        % Call the update method on the nb_optimizerDisplayer to report 
        % results to user.
        
            err = nb_interpretExitFlag(exitFlag,'nb_solve');
            notifyError(displayer,err);
            
        end
        
        function exitFlag = check(options,iter,funEvals)
        % Check if some limits has been breached
        
            exitFlag = 1;
            if options.maxIter <= iter
                exitFlag = 0;
            end
            if options.maxTime <= toc(options.timer)
                exitFlag = -2;
            end
            if options.maxFunEvals <= funEvals
                exitFlag = -3;
            end
            if options.displayer.stopped
                exitFlag = -1;
            end
            
        end
        
        function value = wrapper(x,fHandle,inputs)
           value = fHandle(x,inputs{:}); 
        end
        
    end
    
    methods (Static=true)
        varargout = alphaMethod1(varargin);
        varargout = alphaMethod2(varargin);
        varargout = alphaMethod3(varargin);
        varargout = broyden(varargin);
        varargout = call(varargin);
        varargout = dfsane(varargin);
        varargout = getMethods(varargin);
        varargout = newton(varargin);
        varargout = optimset(varargin);
        varargout = sane(varargin);
        varargout = steffensen(varargin);
        varargout = steffensen2(varargin);
        varargout = test(varargin);
        varargout = test2(varargin);
        varargout = ypl(varargin);
    end
    
end

