function obj = fullSolution(obj)
% Syntax:
%
% obj = fullSolution(obj)
%
% Description:
%
% Update properties of solution when dealing with a DSGE model.
% 
% Input:
% 
% - obj : An object of class nb_dsge. The NB Toolbox parser must be used.
%
% Output:
% 
% - obj : An object of class nb_dsge. See the solution property.
%
% See also:
% nb_dsge.solve, nb_dsge.solveNB
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    parser = obj.estOptions.parser;
    if ~isempty(parser.obs_equations)
        indC = strcmpi(parser.all_exogenous,'Constant');
        endo = parser.all_endogenous;
        res  = parser.all_exogenous;
        res  = res(~indC);
    else
        endo = parser.endogenous;
        res  = parser.exogenous;
    end
    if isfield(obj.solution,'activeShocks')
        res = res(obj.solution.activeShocks);
    end
    nRes  = length(res);
    
    % Empty matrix for the exogenous part of the solution
    obj.solution.vcv = eye(nRes);
    if obj.parser.nBreaks > 0
        obj.solution.vcv = repmat({obj.solution.vcv},[1,obj.parser.nBreaks + 1]);
    end
    
    % Indicate that the NB solver has been used
    obj.solution.endo = endo;
    if iscell(obj.solution.B)
        B = obj.solution.B{1};
    else
        B = obj.solution.B;
    end
    if ~isempty(B)
        obj.solution.exo = {'Constant'};
    else
        obj.solution.exo = {};
    end
    obj.solution.obs   = obj.observables.name;
    obj.solution.res   = res;
    obj.solution.class = 'nb_dsge';
    obj.solution.type  = 'nb';
    if isfield(obj.solution,'CE')
        obj.solution.method = 'expanded';
    else
        obj.solution.method = 'normal';
    end
    obj.solution = nb_rmfield(obj.solution,'activeShocks');
    
end
