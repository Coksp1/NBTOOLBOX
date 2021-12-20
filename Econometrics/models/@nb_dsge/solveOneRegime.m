function [A,B,C,CE,ss,JAC,err] = solveOneRegime(options,beta,skipSolve,silent)
% Syntax:
%
% [A,B,C,CE,ss,JAC,err] = nb_dsge.solveOneRegime(options,beta,skipSolve,silent)
%
% Description:
%
% Solve one regime.
% 
% Input:
% 
% - options   : See the estOptions property of the nb_dsge class.
%
% - beta      : The parameters of the current regime.
%
% - skipSolve : Skip solving for A, B and BE. (They are returned as [])
%
% Output:
% 
% - A       : State transition matrix.
%
% - B       : Constant term.
%
% - C       : The impact of shock matrix.
%
% - CE      : The impact of anticipated shock matrix.
%
% - ss      : Steady state.
%
% - JAC     : Jacobian.
%
% - err     : Non-empty if an error is thrown. If this output is not return
%             a standard error is thrown in the command window.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        silent = true;
        if nargin < 3
            skipSolve = false;
        end
    end

    parser = options.parser;
    paramV = beta;
    if options.estim_steady_state_solve
        
        if ~silent
            t = tic;
            disp('Solving and checking the steady-state of the model...')
        end
        
        % Solve the stead-state    
        pNames       = parser.parameters;
        pKnown       = cell2struct(num2cell(beta),pNames);
        [ss,pSS,err] = nb_dsge.solveSteadyStateStatic(parser,options,pKnown,false);
        if ~isempty(err)    
            [A,B,C,CE,ss,JAC] = errorReturn();
            return
        end
        solution.ss = ss;

        % Assign parameter values solved for in the steady-state (if any!)
        paramNSS = fieldnames(pSS);
        if ~isempty(paramNSS)
            [test,loc] = ismember(paramNSS,pNames);
            if any(~test)
                error([mfilename ':: There has been returned som parameters solved ',...
                    'for in the steady-state that is not a parameter of the model: ',...
                    toString(paramNSS(~test))])
            end
            paramVSS    = struct2cell(pSS);
            paramVSS    = vertcat(paramVSS{:});
            paramV(loc) = paramVSS;
        end

        % Check steady-state
        err = nb_dsge.checkSteadyStateStatic(options,paramV,options.steady_state_tol,ss);
        if ~isempty(err)    
            [A,B,C,CE,ss,JAC] = errorReturn();
            return
        end
        
        % Report
        if ~silent
            elapsedTime = toc(t);
            disp(['Correct! Finished in ' num2str(elapsedTime) ' seconds'])
        end
        
    else
        % In this case we have stored the steady-state solution in the
        % options struct. Done in the nb_dsge.getEstimationOptions method!
        solution.ss = options.ss; 
    end
    
    if ~isempty(options.discount)
        options.discount = nb_dsge.setDiscount(options.discount,pNames,paramV);
    end
    
    % Derivatives
    if ~silent
        t = tic;
        if strcmpi(options.derivativeMethod,'symbolic') 
            disp('Evaluating symbolic 1st order derivatives:')
        else
            disp('Calculating automatic 1st order derivatives:')
        end
    end
    solution = nb_dsge.derivativeNB(parser,solution,paramV);
    if ~silent
        elapsedTime = toc(t);
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
    % Find the solution
    if ~silent
        t = tic;
        disp(' ')
        disp('Solving for the decision rules:')
    end
    if skipSolve
        [A,B,C,CE] = errorReturn();
    else
        [A,B,C,CE,ss,~,err] = nb_dsge.selectSolveAlgorithm(parser,solution,options,false);
    end
    if ~silent
        elapsedTime = toc(t);
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
    if nargout > 4
        JAC = solution.jacobian; 
    end

end

%==========================================================================
function [A,B,C,CE,ss,JAC] = errorReturn()

    A   = [];
    B   = [];
    C   = [];
    CE  = [];
    ss  = [];
    JAC = [];
    
end
