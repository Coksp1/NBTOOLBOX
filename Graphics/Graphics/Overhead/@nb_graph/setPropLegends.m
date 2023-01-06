function setPropLegends(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropLegends(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the legends property of the nb_graph subclasses. This method is 
% used by the set method of nb_graph to set legends and do additional 
% housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object that is a subclass of nb_graph
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                   'legends' for expected behavior). 
%
% - propertyValue : Value to set the legends property to.
%
% Output:
%
% No actual output, but the input object legends property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.(propertyName)    = cellstr(propertyValue);
    obj.manuallySetLegend = 1;

end
