function setPropGraphStruct(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropGraphStruct(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the GraphStruct property of the nb_graph subclasses. This method is 
% used by the set method of nb_graph to set GraphStruct and do additional 
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
%                   'GraphStruct' for expected behavior). 
%
% - propertyValue : Value to set the GraphStruct property to.
%
% Output:
%
% No actual output, but the input object Graph Struct property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ischar(propertyValue)
        eval(propertyValue);
    elseif isstruct(propertyValue)
        obj.(propertyName) = propertyValue;
    else
        % Do nothing. nb_parseInputs have checked that input is either
        % char or struct.
    end
   
end
