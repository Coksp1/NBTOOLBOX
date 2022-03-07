function setPropStartGraph(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropStartGraph(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the startGraph property of the nb_graph_data class. This 
% method is used by the set method of nb_graph to set the 
% startGraph and do some additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph_data') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object of class nb_graph_data. 
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.(propertyName) = propertyValue;
    if ~isempty(obj.DB.endObs)

        if obj.DB.endObs < obj.(propertyName)
            obj.(propertyName) = obj.DB.startObs;
            error([mfilename ':: The ''startGraph'' obs is after the end obs of the dataset (' int2str(obj.DB.endObs) ')'])
        elseif obj.(propertyName) < obj.DB.startObs
            warning('nb_graph_data:startGraphBeforeStartObs',[mfilename ':: The ''startGraph'' obs is before the start obs of the dataset (' int2str(obj.DB.startObs) '). Expands data with nan.']) 
            obj.DB = obj.DB.expand(obj.(propertyName),'','nan','off');
        end

    end
    obj.manuallySetStartGraph = 1; 

end
