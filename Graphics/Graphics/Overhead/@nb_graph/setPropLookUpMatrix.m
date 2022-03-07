function setPropLookUpMatrix(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropLookUpMatrix(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the lookUpMatrix property of the nb_graph subclasses. This method 
% is used by the set method of nb_graph to set lookUpMatrix and do 
% additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object that is a subclass of nb_graph
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                   'lookUpMatrix' for expected behavior). 
%
% - propertyValue : Value to set the lookUpMatrix property to.
%
% Output:
%
% No actual output, but the input object lookUpMatrix property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(propertyValue)
        eval(propertyValue);
    elseif iscell(propertyValue)
        obj.(propertyName) = propertyValue;
    else
        % Do nothing. We have already checked the input in nb_parseInputs.
    end

end
