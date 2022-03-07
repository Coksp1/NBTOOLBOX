function setPropDashedLine(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropBarDashedLine(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the dashedLine property of the nb_graph_ts class. This method 
% is used by the set method of nb_graph to set dashedLine and do 
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
%                   'dashedLine' for expected behavior). 
%
% - propertyValue : Value to set the dashedLine property to.
%
% Output:
%
% No actual output, but the input object dashedLine property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    oldValue       = obj.(propertyName);
    obj.(propertyName) = propertyValue;
    try
        obj.(propertyName);
    catch Err
        obj.(propertyName) = oldValue;
        rethrow(Err);
    end

end
