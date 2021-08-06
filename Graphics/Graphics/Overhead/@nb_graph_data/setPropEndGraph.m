function setPropEndGraph(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropEndGraph(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the endGraph property of the nb_graph_data class. This method 
% is used by the set method of nb_graph to set endGraph and do 
% additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph_data') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object of class nb_graph_data. 
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

    obj.(propertyName) = propertyValue;

    if ~isempty(obj.DB.endObs)

        if obj.DB.endObs < obj.(propertyName)
            warning('nb_graph_data:endGraphAfterEndObs',[mfilename ':: The ''endObs'' obs is after the end obs of the dataset (' int2str(obj.DB.endObs) '). Expands data with nan.']) 
            obj.DB = obj.DB.expand('',obj.endGraph,'nan','off');
        elseif obj.(propertyName) < obj.DB.startObs
            obj.(propertyName) = obj.DB.endObs;
            error([mfilename ':: The ''endGraph'' obs is before the start obs of the dataset (' int2str(obj.DB.startObs) ')'])
        end

    end
    obj.manuallySetEndGraph = 1;   

end
