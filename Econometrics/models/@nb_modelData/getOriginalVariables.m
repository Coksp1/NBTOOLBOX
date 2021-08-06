function vars = getOriginalVariables(obj)
% Syntax:
%
% vars = getOriginalVariables(obj)
%
% Description:
%
% Get the variables of the original data source assign to the model.
% 
% Input:
% 
% - obj  : An object of class nb_model_generic.
%
% Output:
% 
% - vars : A cellstr with the variables of the original data source.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only handle scalar object.'])
    end
    vars = obj.dataOrig.variables;

end
