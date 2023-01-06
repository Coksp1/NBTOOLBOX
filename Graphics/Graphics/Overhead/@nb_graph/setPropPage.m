function setPropPage(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropPage(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the page property of the nb_graph subclasses. This method 
% is used by the set method of nb_graph to set page and do 
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
%                   'page' for expected behavior). 
%
% - propertyValue : Value to set the page property to.
%
% Output:
%
% No actual output, but the input object page property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if propertyValue < 1 || propertyValue > obj.DB.numberOfDatasets
        error([mfilename ':: The input after the ''page'' property is not a page of the data object.'])
    else
        obj.(propertyName) = propertyValue;
    end

end
