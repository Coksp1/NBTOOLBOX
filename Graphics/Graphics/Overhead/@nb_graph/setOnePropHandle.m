function setOnePropHandle(obj,propertyName,propertyValue)
% Syntax:
% 
% setOnePropHandle(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set properties of the nb_graph class and its subclasses.
%
% This function is used to set properties which require only simple checks
% and no additional tasks to be done.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object that is a subclass of nb_graph
% 
% - propertyName  : n x 1 char. Propertyname to set.
%
% - propertyValue : Value to set the property to.
%
% Output:
%
% No actual output, but the input object property will have been set to 
% their new value.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.(propertyName) = propertyValue;

end
