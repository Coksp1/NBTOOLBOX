function dumpSteadyState(obj,ss)
% Syntax:
%
% dumpSteadyState(obj,ss)
%
% Description:
% 
% Dump parameters and steady-state values in the case of an error while
% solving the steady state.
%
% Input:
% 
% - obj                  : An object of class nb_dsge.
%
% See also:
% nb_dsge.checkSteadyState, nb_dsge.solveSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2 % Called from nb_dsge.checkSteadyState
        ss   = obj.solution.ss;
        endo = obj.parser.endogenous';
    else % Called from nb_dsge.solveSteadyState
        endo = obj.parser.endogenous(~obj.parser.isAuxiliary);
    end
    if isfield(obj.parser,'isMultiplier')
        endo = endo(~obj.parser.isMultiplier);
    end
    ss = nb_ss(ss);
    for ii = 1:length(endo)
        assignin('base',endo{ii},ss(ii));
    end
    param = getParameters(obj);
    for ii = 1:size(param,1)
        assignin('base',param{ii,1},param{ii,2});
    end

end
