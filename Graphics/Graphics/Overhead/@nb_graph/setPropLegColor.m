function setPropLegColor(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropLegColor(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the legColor property of the nb_graph subclasses. This method is 
% used by the set method of nb_graph to set legColor and do additional 
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
%                   'legColor' for expected behavior). 
%
% - propertyValue : Value to set the legColor property to.
%
% Output:
%
% No actual output, but the input object legColor property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isnumeric(propertyValue) || strcmpi(propertyValue,'none')
        obj.(propertyName) = propertyValue;
    elseif ischar(propertyValue) || iscellstr(propertyValue) %#ok<ISCLSTR>
        obj.(propertyName) = nb_plotHandle.interpretColor(propertyValue);
    else
        error([mfilename ':: The input after the ''legColor'' property must be a 1x3 double with the RGB color specification or a string with the name of the color.'])
    end  

end
