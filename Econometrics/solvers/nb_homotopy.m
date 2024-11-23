function [x,fVal,exitflag,err] = nb_homotopy(algorithm,steps,start,finish,names,solveFunc,fHandle,init,options,varargin)
% Syntax:
%
% x                     = nb_homotopy(algorithm,steps,start,finish,...
%                           names,solveFunc,fHandle,options)
% [x,fVal,exitflag,err] = nb_homotopy(algorithm,steps,start,finish,...
%                           names,solveFunc,fHandle,init,options,varargin)
%
% Description:
%
% Find the solution of the problem F(x) = 0 using homotopy.
%
% At each step of the homotopy algorithm the solver function (solveFunc) 
% will be called.
%
% Caution: It is assumed that the problem can be solved with the parameters
%          in start with the given initial conditions.
%
% Input:
% 
% - algorithm : Either 1, 2 or 3. 
%
%   > 1: The problem is solved iterativly. Starting with the vector of
%        parameters in start until it reaches the parameter vector finish.
%        All the parameters will changes at the same time. This means that
%        the problem is solved steps times.
%
%   > 2: Same as 1, but know the only one parameter is change at each 
%        recursion. One step of this algorithm is when all the parameters
%        have changed. This means that the problem is solved nParam x 
%        steps times.
%
%   > 3: Now it tries to solve the problem at finish with the solution
%        from the parameters in start as the intial condition. If this
%        fails, it will try to solve it with the parameter that are the mid
%        point between start and finish. If that fails, it splits this
%        interval in two again, and it will continue in this way until it
%        finds a point it can solve the problem. It will do this for each
%        sub interval until it reaches the parameter vector finish.
%
% - steps     : Depends on the algorithm input.
%
%   > 1: The number of recursive steps from the start vector of parameters
%        until the finish vector of parameter. 
%
%   > 2: The number of recursive steps from the start vector of parameters
%        until the finish vector of parameter. 
%
%   > 3: The maximum number of allowed steps of this algorithm. 
%   
% - start     : The nParam x 1 parameter vector at the starting point, 
%               where we assume we already know that the problem can be 
%               solved.
%
% - finish    : The nParam x 1 parameter vector at the finishing point. 
%               This point is the point where we are really interested in
%               solving the problem.
%
% - names     : A cellstr with the names of the parameters to do the
%               homotopy over. If given as empty default names will be
%               given. This is to throw a correct error message when
%               homotopy algorithm 2 fails.
%
% - solveFunc : See the same input to the nb_solver function.
% 
% - fHandle   : See the same input to the nb_solver function.
%
% - init      : See the same input to the nb_solver function.
%
% - options   : See the same input to the nb_solver function. To prevent
%               it from printing iteration on the command line set
%               the silent field to true.
%
% Optiona input:
%
% - varargin  : See the same input to the nb_solver function.
%
% Output:
% 
% - x         : The solution of the problem F(x) = 0, as a vector of 
%               double values.
%
% - fVal      : The value of F(x) at the return x.
%
% - exitflag  : The exit flag return by the solver. If only to outputs are
%               returned this exit flag will be interpreded by the
%               nb_interpretExitFlag and an error will be thrown by inside
%               this function.
%
% - err       : A struct with the information on the error during the
%               homotopy steps. Empty if no errors occure. This can be  
%               given to the nb_interpretExitFlag function to throw a 
%               generic error message. The fields are:
%
%       > iter      : If exitflag return that the problem could not be  
%                     solve, this output will give the iteration number it  
%                     first failed. Otherwise it is empty. For algorithm 2 
%                     this will be a 1x2 double, where the 2 element is 
%                     the parameter index it failed.
%
%       > points    : If exitflag return that the problem could not be 
%                     solve, this output will give the parameter vector it  
%                     first failed.
%
%       > algorithm : Same as the algorithm input.
%
%       > names     : Same as the names input.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    display = true;
    if isfield(options,'silent')
        display = ~options.silent;
    end
    
    iter = [];
    switch algorithm
        
        case 1
             
            points = nb_linespace(start',finish',steps+1);
            points = points(:,2:end);
            for ii = 1:steps
                [x,fVal,exitflag] = nb_solver(solveFunc,fHandle,init,options,points(:,ii),varargin{:});
                if exitflag < 1
                    iter   = ii;
                    points = points(:,ii);
                    break
                end
                init = x;
                
                if display
                    disp(['Finished with homotopy step ' int2str(ii) ' of ' int2str(steps) '...'])
                end
            end
            
        case 2
            
            points = nb_linespace(start',finish',steps+1);
            looped = find(abs(points(:,2) - points(:,1)) > 0); % Locate the parameters that are changed
            for ii = 2:steps+1
                for jj = looped
                    
                    % Change only one parameter at the time
                    pointsT       = points(:,ii-1);
                    pointsT(1:jj) = points(1:jj,ii);
                    
                    % Try to solve the problem
                    [x,fVal,exitflag] = nb_solver(solveFunc,fHandle,init,options,pointsT,varargin{:});
                    if exitflag < 1
                        iter   = [ii-1,jj];
                        points = pointsT;
                        break
                    end
                    init = x;
                    
                end
                
                if display
                    disp(['Finished with homotopy step ' int2str(ii-1) ' of ' int2str(steps) '...'])
                end
            end
            
        case 3
            
            iter   = 0;
            points = [start,finish];
            index  = 2;
            [x,fVal,exitflag,iter,points] = splitAndSolve(iter,index,steps,points,solveFunc,fHandle,init,options,display,varargin);
            
        otherwise
            if isnumeric(algorithm)
                algorithm = int2str(algorithm);
            elseif ~nb_isOneLineChar(algorithm)
                error([mfilename ':: The homotopy algorithm must be an integer.'])
            end
            error([mfilename ':: Unsupported homotopy algorithm ' algorithm])
    end
    
    if exitflag < 1
        looped = abs(points(:,2) - points(:,1)) > 0; % Locate the parameters that are changed
        if isempty(names) || ~iscellstr(names)
            names = nb_appendIndexes('Param',1:size(start,1));
        else
            if length(names) ~= size(start,1)
                names = nb_appendIndexes('Param',1:size(start,1));
            end
        end
        err = struct('algorithm',algorithm,'iter',iter,'names',{names},'points',points(looped));
    else
        err = [];
    end

end

%==========================================================================
function [x,fVal,exitflag,iter,points] = splitAndSolve(iter,index,steps,points,solveFunc,fHandle,init,options,display,inputs)

    [x,fVal,exitflag] = nb_solver(solveFunc,fHandle,init,options,points(:,index),inputs{:});
    if display
        disp(['Homotopy iteration ' int2str(iter) ' of maximum ' int2str(steps) ' iterations...'])
    end
    if exitflag < 1
        iter = iter + 1;
        if steps < iter
            iter   = steps;
            points = points(:,index);
            return
        end
        midPoint = points(:,index-1)*0.5 + points(:,index)*0.5;  
        points   = [points(:,1:index-1),midPoint,points(:,index:end)];
        [x,fVal,exitflag,iter,points] = splitAndSolve(iter,index,steps,points,solveFunc,fHandle,init,options,display,inputs);
    elseif index + 1 < size(points,2)
        iter = iter + 1;
        init = x;
        [x,fVal,exitflag,iter,points] = splitAndSolve(iter,index+1,steps,points,solveFunc,fHandle,init,options,display,inputs);
    end

end
