function obj = setParametersInUse(obj,parameters)
% Syntax:
%
% obj = setParametersInUse(obj,parameters)
%
% Description:
%
% Indicate that the parameter is in use even if the parser has failed to
% detect that. 
% 
% Input:
% 
% - obj        : An object of class nb_dsge.
%
% - parameters : A cellstr with the parameters to indicate are in use.
% 
% Output:
% 
% - obj        : An object of class nb_dsge.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ind = ismember(parameters,obj.parameters.name);
    if any(~ind)
        error([mfilename ':: The following parameters are not declared; ' toString(parameters(~ind))])
    end
    ind = ismember(obj.parameters.name,parameters);
    obj.parser.parametersInUse = obj.parser.parametersInUse | ind(:)';
    
end
