function setPropChar2Cellstr(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropChar2Cellstr(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the properties of the nb_graph subclasses that take either a char 
% or a cellstr as an input, but in any case we want to save the cellstr 
% version. This method is used by the set method of nb_graph to set various
% properties.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object that is a subclass of nb_graph
% 
% - propertyName  : n x 1 char. Propertyname to set.. 
%
% - propertyValue : Value to set the property to.
%
% Output:
%
% No actual output, but the input object property will have been set to the 
% new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if iscell(propertyValue)
        obj.(propertyName) = propertyValue;
    elseif ischar(propertyValue)
        obj.(propertyName) = cellstr(propertyValue);
    else
        % Do nothing. nb_parseInputs have checked that input is either
        % cell or char.
    end
   
end
