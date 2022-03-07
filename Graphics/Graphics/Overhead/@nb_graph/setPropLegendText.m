function setPropLegendText(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropLegendText(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the legendText property of the nb_graph subclasses. This method is 
% used by the set method of nb_graph to set legendText and do additional 
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
%                   'legendText' for expected behavior). 
%
% - propertyValue : Value to set the legendText property to.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.(propertyName)    = propertyValue;
    obj.manuallySetLegend = 1;

end
