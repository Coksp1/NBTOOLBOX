function setPropEndGraph(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropEndGraph(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the endGraph property of the nb_graph_ts class. This method 
% is used by the set method of nb_graph to set endGraph and do 
% additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph_ts') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object of class nb_graph_ts. 
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                   'endGraph' for expected behavior). 
%
% - propertyValue : Value to set the endGraph property to.
%
% Output:
%
% No actual output, but the input object endGraph property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.(propertyName)      = propertyValue;
    obj.manuallySetEndGraph = 1;
    if ~isempty(obj.DB.endDate)
        if obj.DB.endDate < obj.(propertyName)
            warning('nb_graph_ts:endGraphAfterEndDate',[mfilename ':: The ''endGraph'' date is after the end date of the dataset (' obj.DB.endDate.toString() '). Expands data with nan.']) 
            obj.DB = obj.DB.expand('',obj.(propertyName),'nan','off');
        elseif obj.(propertyName) < obj.DB.startDate
            obj.(propertyName) = obj.DB.endDate;
            error([mfilename ':: The ''endGraph'' date is before the start date of the dataset (' obj.DB.startDate.toString() ')'])
        end

    end

end
