function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_highlight
% 
% Input:
% 
% - obj           : An object of class nb_highlight
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('children');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch propertyName

        case 'cdata'

            propertyValue = obj.cData;

        case 'children'

            propertyValue = obj.children;    

        case 'deleteoption'

            propertyValue = obj.deleteOption;

        case 'legendinfo'

            propertyValue = obj.legendInfo;

        case 'parent'

            propertyValue = obj.parent; 

        case 'type'

            propertyValue = obj.type; 

        case 'visible'

            propertyValue = obj.visible; 

        case 'xdata'

            propertyValue = obj.xData;

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
