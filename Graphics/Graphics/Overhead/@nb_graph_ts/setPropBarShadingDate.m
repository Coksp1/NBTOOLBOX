function setPropBarShadingDate(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropBarShadingDate(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the barShadingDate property of the nb_graph_ts class. This method 
% is used by the set method of nb_graph to set barShadingDate and do 
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
%                   'barShadingDate' for expected behavior). 
%
% - propertyValue : Value to set the barShadingDate property to.
%
% Output:
%
% No actual output, but the input object barShadingDate property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(propertyValue) || isa(propertyValue,'nb_date')

        oldValue = obj.(propertyName);
        try
            obj.(propertyName) = propertyValue;
        catch Err
            obj.(propertyName) = oldValue;
            rethrow(Err);
        end

    elseif iscell(propertyValue)

        oldValue = obj.(propertyName);
        try
            obj.(propertyName) = propertyValue;
        catch Err
            obj.(propertyName) = oldValue;
            rethrow(Err);
        end
    end

end
