function vars = getModelVars(obj,~)
% Syntax:
%
% vars = getModelVars(obj)
% vars = getModelVars(obj,varsIn)
%
% Description:
%
% Get all variables to the model. That include dependent and exogenous 
% variables.
%
% For factor models the observables are added as well.
% 
% Input:
% 
% - obj    : A scalar nb_model_generic object.
%
% - varsIn : Not in use!
% 
% Output:
% 
% - vars : A cellstr array with the variables of the model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: Only scalar nb_model_generic object are supported.'])
    end

    vars = {};
    if isprop(obj,'dependent')
        vars = [vars,obj.dependent.name];
    end
    if isprop(obj,'exogenous')
        vars = [vars,obj.exogenous.name];
    end
    if isprop(obj,'observables')
        vars = [vars,obj.observables.name];
    end

end
