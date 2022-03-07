function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_area
% 
% Input:
% 
% - obj           : An object of class nb_area
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

    switch lower(propertyName)

        case 'appendwhite'
                    
            propertyValue = obj.appendWhite;
        
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

        case 'side'

            propertyValue = obj.side;    

        case 'type'

            propertyValue = obj.type;    

        case 'visible'

            propertyValue = obj.visible;    

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
