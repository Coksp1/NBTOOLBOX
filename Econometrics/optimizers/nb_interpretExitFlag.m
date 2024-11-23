function message = nb_interpretExitFlag(e,type,extra,homotopyErr)
% Syntax:
%
% nb_interpretExitFlag(e,type)
% message = nb_interpretExitFlag(e,type,extra,homotopyErr)
%
% Description:
%
% Interpret error from given optimizers or zero root finders.
% 
% If nargout == 1, the error will not be thrown! Instead the error message
% will be returned.
%
% Input:
%
% - e           : The exit flag of the given optimizer or solver.
%
% - type        : The optimizer or solver used as a string. E.g. 
%                 'fmincon', 'fminsearch', 'fsolve', etc.
%
% - extra       : A string with extra information on the error. Will be
%                 appended. Default is ''.
%
% - homotopyErr : If nb_homotopy is used you can provide the err output
%                 of that function as this input.
%
% Output:
%
% - message     : If asked for the error message is returned instead of
%                 thrown.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        homotopyErr = [];
        if nargin < 3
            extra = '';
        end
    end
    
    if isstruct(homotopyErr)
        
        if e < 1 && homotopyErr.algorithm > 0

            iter = homotopyErr.iter;
            switch homotopyErr.algorithm
                case 1
                    homotopyExtra = ['\n\n Homotopy algorithm 1 quit at iteration ' int2str(iter) '.'];
                case 2
                    names         = homotopyErr.names;
                    homotopyExtra = ['\n\n Homotopy algorithm 2 quit at iteration ' int2str(iter(1)) ' and parameter ' names{iter(2)} '.'];
                case 3
                    homotopyExtra = ['\n\n Homotopy algorithm 3 quit at iteration ' int2str(iter) '.'];
            end

            table         = cell(size(homotopyErr.points,1),2);
            table(:,1)    = homotopyErr.names';
            table(:,2)    = nb_double2cell(homotopyErr.points,'%8.6f');
            tableAsChar   = cellstr(cell2charTable(table));
            tableAsChar   = strcat(tableAsChar,'\n');
            tableAsChar   = horzcat(tableAsChar{:});
            homotopyExtra = [homotopyExtra, ' See list below for the values of the parameters/variables for when the homotopy algorithm stopped;\n\n',tableAsChar];
            extra         = [extra,sprintf(homotopyExtra)];
            
        end
        
    else
        message = '';
    end

    switch lower(type)   
        case 'fminsearch'

            if e == 1
                return
            elseif e == 0
                message = ['Error during fminsearch:: Too many function evaluations or iterations.',extra];
            elseif e == -1
                message = ['Error during fminsearch:: Stopped by output/plot function.',extra];
            else
                message = ['Error during fminsearch.',extra];
            end
            
        case 'fsolve'
            
            if e > 0
                return
            elseif e == 0
                message = ['Error during fsolve:: Too many function evaluations or iterations.',extra];
            elseif e == -1
                message = ['Error during fsolve:: Stopped by output/plot function.',extra];
            elseif e == -2
                message = ['Error during fsolve:: Converged to a point that is not a root.',extra];
            elseif e == -3
                message = ['Error during fsolve:: Trust region radius too small (Trust-region-dogleg).',extra];    
            end 
            
        case 'fmincon'
            
            if e == 0
                message = ['Error during fmincon:: Too many function evaluations or iterations.',extra];
            elseif e == -1
                message = ['Error during fmincon:: Stopped by output/plot function.',extra];
            elseif e == -2
                message = ['Error during fmincon:: No feasible point found.',extra];
            elseif e == -3
                message = ['Error during fmincon:: Problem seems unbounded.',extra];
            end 
            
        case 'fminunc'
            
            if e == 0
                message = ['Error during fminunc:: Too many function evaluations or iterations.',extra];
            elseif e == -1
                message = ['Error during fminunc:: Stopped by output/plot function.',extra];
            elseif e == -3
                message = ['Error during fminunc:: Problem seems unbounded.',extra];
            end     
            
        case 'linprog'
            
            if e == 0
                message = ['Error during linprog:: Maximum number of iterations reached.',extra];
            elseif e == -2
                message = ['Error during linprog:: No feasible point found.',extra];
            elseif e == -3
                message = ['Error during linprog:: Problem is unbounded.',extra];
            elseif e == -4
                message = ['Error during linprog:: NaN value encountered during execution of algorithm.',extra];
            elseif e == -5
                message = ['Error during linprog:: Both primal and dual problems are infeasible.',extra];   
            elseif e == -7
                message = ['Error during linprog:: Magnitude of search direction became too small; no further progress can be made. The problem is ill-posed or badly conditioned.',extra];    
            end 
            
        case 'nb_fmin'
            
            if e == 0
                message = ['Error during nb_fmin:: Too many function evaluations.',extra];
            elseif e == -1
                message = ['Error during nb_fmin:: Too many iterations.',extra];
            end 
            
        case {'bee_gate','nb_abc'}
            
            % No exitflags trigger an error, as these algorithms allways stops with a negative exit flag!
            
        case 'nb_pso'
            
            if e == 0
                message = ['Error during nb_pso:: Maximum number of iterations reached.',extra];
            elseif e == -1
                message = ['Error during nb_pso:: Optimization stopped by user.',extra];
            elseif e == -4
                message = ['Error during nb_pso:: The value of the objective did not improve over the last stall ',...
                           'time period spesified by the StallTimeLimit option.',extra];
            elseif e == -5
                message = ['Error during nb_pso:: Maximum time limit reached.',extra];    
            end 
            
        case 'csminwel'
            
            switch e
                case 1
                    message = ['Zero gradient.', extra];
                case 3
                    message = ['Smallest step still improving too slow.', extra];    
                case 6
                    message = ['Smallest step still improving too slow, reversed gradient.', extra];
                case 5
                    message = ['Largest step still improving too fast.', extra];
                case {2,4}
                    message = ['back and forth on step length never finished.', extra];
            end
            
        case 'nb_solve'
            
            if e == 0
                message = ['Error during nb_solve:: Maximum number of iterations reached.',extra];
            elseif e == -1
                message = ['Error during nb_solve:: Optimization stopped by user.',extra];
            elseif e == -2
                message = ['Error during nb_solve:: Maximum time limit reached.',extra];   
            elseif e == -3
                message = ['Error during nb_solve:: Maximum number of function evaluations reached.',extra];
            elseif e == -4
                message = ['Error during nb_solve:: Could not invert jacobian.',extra];
            elseif e == -5
                message = ['Error during nb_solve:: Jacobian contain nan or inf values a last iteration.',extra];  
            elseif e == -6
                message = ['Error during nb_solve:: Function return nan or inf values a last iteration.',extra];    
            end

        case 'nb_abcsolve'
            
            if e > 0
                return
            else
                message = nb_abcsolve.interpretExitFalg(e);
                message = [message,extra];  
            end
            
        case 'nb_lasso'
            
            if e == -1
                message = ['Error during nb_lasso:: Numerical breakdown, check for dependent columns.',extra];
            elseif e == -2
                message = ['Error during nb_lasso:: Maximum number of iteration reached.',extra];      
            end
            
        case 'lsqnonlin'
            
            if e == 0
                message = ['Error during lsqnonlin:: Too many function evaluations or iterations.',extra];
            elseif e == -1
                message = ['Error during lsqnonlin:: Stopped by output/plot function.',extra];    
            elseif e == -2
                message = ['Error during lsqnonlin:: Bounds are inconsistent.',extra];    
            end
            
        otherwise
            if e < 0
                message = [mfilename ':: Error during call to the optimizer; ' type '. Exit flag ' int2str(e) '.' extra];
            end
    end
    
    if nargout < 1  
        messageState = getenv('optimizerMessageState');
        if strcmpi(messageState,'true')
            warning('nb_interpretExitFlag:warning',message)
        else
            error(message)
        end
    end
    
end
