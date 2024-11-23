function setPropStartGraph(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropStartGraph(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the startGraph property of the nb_graph_ts class. This 
% method is used by the set method of nb_graph to set the 
% startGraph and do some additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph_ts') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object of class nb_graph_ts. 
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                 'startGraph' for expected behavior). 
%
% - propertyValue : Value to set the startGraph property to.
%
% Output:
%
% No actual output, but the input object startGraph property will have been 
% set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.(propertyName)        = propertyValue;
    obj.manuallySetStartGraph = 1;
    if ~isempty(obj.DB.endDate)
        if obj.DB.endDate < obj.startGraph
            obj.(propertyName) = obj.DB.startDate;
            error([mfilename ':: The ''startGraph'' date is after the end date of the dataset (' obj.DB.endDate.toString() ')'])
        elseif obj.(propertyName) < obj.DB.startDate
            warning('nb_graph_ts:startGraphBeforeStartDate',[mfilename ':: The ''startGraph'' date is before the start date of the dataset (' obj.DB.startDate.toString() '). Expands data with nan.']) 
            obj.DB = obj.DB.expand(obj.startGraph,'','nan','off');
        end
    end

end
