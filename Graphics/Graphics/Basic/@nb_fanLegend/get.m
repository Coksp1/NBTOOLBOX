function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_title
% 
% Input:
% 
% - obj           : An object of class nb_title
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch propertyName

        case 'children'

            propertyValue = obj.children;

        case 'deleteoption'

            propertyValue = obj.deleteOption; 

        case 'fontname'

            propertyValue = obj.fontName;

        case 'fontsize'

            propertyValue = obj.fontSize; 

        case 'fontunits'

            propertyValue = obj.fontUnits;    
            
        case 'fontweight'

            propertyValue = obj.fontWeight; 

        case 'interpreter'

            propertyValue = obj.interpreter; 
            
        case 'location'
                    
            propertyValue = obj.location;            

        case 'parent'

            propertyValue = obj.parent; 

        case 'string'

            propertyValue = obj.string; 

        case 'visible'

            propertyValue = obj.visible;

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
