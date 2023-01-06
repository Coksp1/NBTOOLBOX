function obj = updateGivenObsModel(obj)
% Syntax:
%
% obj = updateGivenObsModel(obj)
%
% Description:
%
% Update model properties given that the model is solved with an added
% observation model.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Update list of endogenous 
    obj.dependent.name        = obj.parser.all_endogenous;
    obj.dependent.tex_name    = strrep(obj.parser.all_endogenous,'_','\_');
    obj.dependent.number      = length(obj.dependent.name);
    obj.dependent.isAuxiliary = obj.parser.all_isAuxiliary';
    obj.endogenous            = obj.dependent;
    
    % Update list of exogenous 
    obj.exogenous.name        = obj.parser.all_exogenous;
    obj.exogenous.tex_name    = strrep(obj.parser.all_exogenous,'_','\_');
    obj.exogenous.number      = length(obj.exogenous.name);
    
end
