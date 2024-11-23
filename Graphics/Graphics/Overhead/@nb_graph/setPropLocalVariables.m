function setPropLocalVariables(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropLocalVariables(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the localVariables property of the nb_graph subclasses. This method 
% is used by the set method of nb_graph to set localVariables and do 
% additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object that is a subclass of nb_graph
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                   'localVariables' for expected behavior). 
%
% - propertyValue : Value to set the localVariables property to.
%
% Output:
%
% No actual output, but the input object localVariables property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        obj.(propertyName) = nb_structcat(propertyValue,obj.DB.localVariables);
    catch Err
        error([mfilename ':: Could not merge the local variables you try to set with the local variables defined by the data source. ' Err.message])
    end
    obj.DB.localVariables = obj.localVariables;

end
