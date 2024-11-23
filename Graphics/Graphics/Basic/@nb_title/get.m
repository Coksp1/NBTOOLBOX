function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_fanLegend
% 
% Input:
% 
% - obj           : An object of class nb_fanLegend
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch propertyName

        case 'alignment'
                    
            propertyValue = obj.alignment; 
        
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

        case 'normalized'
                    
        	propertyValue = obj.normalized;       
            
        case 'parent'

            propertyValue = obj.parent; 

        case 'placement'
                    
            propertyValue = obj.placement; 
    
        case 'string'

            propertyValue = obj.string; 

        case 'visible'

            propertyValue = obj.visible;

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
