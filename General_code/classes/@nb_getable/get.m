function value = get(obj,propertyName)
% Syntax:
% 
% get(obj,propertyName)
% 
% Description:
% 
% Gets the property of an object of class nb_getable. 
% 
% Input:
% 
% - obj          : An object of class nb_getable.
% 
% - propertyName : Name of the proeprty to get the value of, as a string.
% 
% Output:
% 
% - value        : The value of the property asked for.
% 
% Examples:
% 
% fig = obj.get('parent');
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 0
        value = struct(obj);
        return
    end
    props = properties(obj);
    ind   = strcmpi(propertyName,props);
    if any(ind)
        value = obj.(props{ind}); 
    else
        error([mfilename ':: Bad property name ''' propertyName ''' for object of class ' class(obj) '.'])
    end

end
