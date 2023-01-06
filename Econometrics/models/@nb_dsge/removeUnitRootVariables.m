function parser = removeUnitRootVariables(parser)
% Syntax:
% 
% parser = nb_dsge.removeUnitRootVariables(parser)
%
% Description:
%
% Convert equation of the model to a function handle. Subroutine. 
%
% Static private method.
% 
% Input:
%
% - parser : See the parser property of the nb_dsge class.
%
% - eqs    : A nEq x 1 cellstr array with the equations of the model.
%
% - static : Give true to indicate that you want the static representation
%            of the model.
%
% See also:
% nb_dsge.parse, nb_dsge.addEquation, nb_dsge.solveSteadyStateStatic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isfield(parser,'equationsParsed')
        nUnitRoot = length(parser.unitRootVars);
        eqs       = parser.equationsParsed;
        for ii = 1:nUnitRoot
            pattern = strcat('(?<![A-Za-z_])',parser.unitRootVars{ii},'\>');
            eqs     = regexprep(eqs,pattern,'1');

        end
        parser.equationsParsed = eqs;
    end

end
