function obj = updateGivenOptimalPolicy(obj)
% Syntax:
%
% obj = updateGivenOptimalPolicy(obj)
%
% Description:
%
% Update model properties given optimal monetary policy solution.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
%
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% nb_dsge.solveNB
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Update list of endogenous 
    obj.dependent.name        = obj.parser.endogenous;
    mult                      = obj.parser.endogenous(obj.parser.isMultiplier);
    ind                       = ~nb_contains(obj.dependent.tex_name,'mult\_');
    obj.dependent.tex_name    = [obj.dependent.tex_name(ind),strrep(mult,'_','\_')];
    obj.dependent.number      = length(obj.dependent.name);
    obj.dependent.isAuxiliary = obj.parser.isAuxiliary';
    obj.endogenous            = obj.dependent;
    
end
