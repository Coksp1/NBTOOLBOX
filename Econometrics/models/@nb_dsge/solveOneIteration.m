function [A,B,C,CE,ss,paramV,err] = solveOneIteration(options,results,obs)
% Syntax:
%
% [A,B,C,CE,ss,paramV,err] = nb_dsge.solveOneIteration(options,results,obs)
%
% Description:
%
% Solve model given current level of trends.
% 
% Input:
% 
% - options : See the estOptions property of the nb_dsge class.
%
% - results : See the results property of the nb_dsge class.
%
% - obs     : A struct with the current values of the endogenous variables
%             of the model.
%
% Output:
% 
% - A   : State transition matrix.
%
% - B   : The impact of exogenous variables matrix.
%
% - C   : The impact of shock matrix.
%
% - CE  : The impact of anticipated shock matrix.
%
% - ss  : The steady state, or point of approximation.
%
% - err : Non-empty if an error is thrown. If this output is not return
%         a standard error is thrown in the command window.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    parser = options.parser;
    paramV = results.beta;
    
    % Convert current observations of the endogenous variable to struct
    if ~isempty(parser.all_endogenous)
        endo = parser.all_endogenous;
    else
        endo = parser.endogenous;
    end
    options.steady_state_obs = cell2struct(num2cell(obs),endo);
    
    % Solve the stead-state    
    pNames       = parser.parameters;
    pKnown       = cell2struct(num2cell(paramV),pNames);
    [ss,pSS,err] = nb_dsge.solveSteadyStateStatic(parser,options,pKnown,false);
    if ~isempty(err)    
        [A,B,C,CE,ss] = errorReturn();
        return
    end
    solution.ss = ss;

    % Assign parameter values solved for in the steady-state (if any!)
    paramNSS = fieldnames(pSS);
    if ~isempty(paramNSS)
        [~,loc]     = ismember(paramNSS,pNames);
        paramVSS    = struct2cell(pSS);
        paramVSS    = vertcat(paramVSS{:});
        paramV(loc) = paramVSS;
    end

    % Check steady-state
    err = nb_dsge.checkSteadyStateStatic(options,paramV,options.steady_state_tol,ss);
    if ~isempty(err)    
        [A,B,C,CE,ss] = errorReturn();
        return
    end
        
    if ~isempty(options.discount)
        options.discount = nb_dsge.setDiscount(options.discount,pNames,paramV);
    end
    
    % Derivatives
    [solution,err] = nb_dsge.derivativeNB(parser,solution,paramV);
    if ~isempty(err)    
        [A,B,C,CE,ss] = errorReturn();
        return
    end
    
    % Find the solution
    [A,B,C,CE,ss,~,err] = nb_dsge.selectSolveAlgorithm(parser,solution,options,false);

end

%==========================================================================
function [A,B,C,CE,ss] = errorReturn()

    A  = [];
    B  = [];
    C  = [];
    CE = [];
    ss = [];
    
end
