function setPropColorOrder(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropColorOrder(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the colorOrder and colorOrderRight property of the nb_graph 
% subclasses. This method is used by the set method of nb_graph to set 
% colorOrders and do additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object that is a subclass of nb_graph
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                   'colorOrder' / 'colorOrderRight for expected behavior). 
%
% - propertyValue : Value to set the colorOrder property to.
%
% Output:
%
% No actual output, but the input object colorOrder property will have been 
% set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isnumeric(propertyValue)
        obj.(propertyName) = propertyValue;
    elseif iscellstr(propertyValue) %#ok<*ISCLSTR>
        obj.(propertyName) = nb_plotHandle.interpretColor(propertyValue);
    else
        % Do nothing. Checked for by nb_parseInputs so will never get here.
    end
    
    if strcmpi(propertyName,'colororder')
        obj.manuallySetColorOrder = 1;
    else
        obj.manuallySetColorOrderRight = 1;
    end

end
