function eqs = getStaticEquations(eqs,parser)
% Syntax:
% 
% eqs = nb_dsge.getStaticEquations(eqs,parser)
%
% Description:
%
% Get static version of the model. 
%
% Static private method.
% 
% Input:
%
% - eqs    : A nEq x 1 cellstr array with the equations of the model.
%
% - parser : See the parser property of the nb_dsge class.
%
% See also:
% nb_dsge.solveSteadyStateStatic, nb_dsge.eqs2funcSub
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Substitute in the static equations, i.e. the equations that uses
    % the [static] syntax
    if ~isempty(parser.static)
        eqs(parser.staticLoc) = parser.static; 
    end

    % Add the static equation given as an option to the planner_objective
    % command. 
    if isfield(parser,'optimalstatic')
        if ~isempty(parser.optimalstatic)
            eqs = [eqs;parser.optimalstatic];
        end
    end
    
    % Add the static equation given in the static block, this block can
    % be used to back out parameters given restrictions on the endogenous
    % variables of the model.
    if isfield(parser,'staticEquations')
        if ~isempty(parser.staticEquations)
            eqs = [eqs;parser.staticEquations];
        end
    end
    
end
