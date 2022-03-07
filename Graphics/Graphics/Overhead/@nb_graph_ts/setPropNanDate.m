function setPropNanDate(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropNanDate(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the nanDate properties of the nb_graph_ts class. This method 
% is used by the set method of nb_graph to set the nanAfterDate and the 
% nanBeforeDate properties.
%
% See documentation NB Toolbox or type help('nb_graph_ts') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object of class nb_graph_ts. 
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                 'nanBeforeDate' or 'nanAfterDate' for expected behavior). 
%
% - propertyValue : Value to set the nanDate property to.
%
% Output:
%
% No actual output, but the input object nanDate property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.(propertyName) = nb_date.toDate(propertyValue,obj.DB.frequency);

end
