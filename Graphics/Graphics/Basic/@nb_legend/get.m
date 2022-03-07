function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_legend
% 
% Input:
% 
% - obj           : An object of class nb_legend
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('baseline');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The ''propertyName'' input must be a string.'])
    end

    switch lower(propertyName)

        case 'box'

            propertyValue = obj.box;
            
        case 'children'
            
            propertyValue = obj.children;

        case 'color'

            propertyValue = obj.color;

        case 'columns'

            propertyValue = obj.columns;

        case 'columnwidth'

            propertyValue = obj.columnWidth;

        case 'deleteoption'

            propertyValue = obj.deleteOption;    

        case 'fakelegends'
                    
            propertyValue = obj.fakeLegends;     
            
        case 'fontname'

            propertyValue = obj.fontName;

        case 'fontsize'

            propertyValue = obj.fontSize;
            
        case 'fontunits'
            
            propertyValue = obj.fontUnits;

        case 'fomtweight'

            propertyValue = obj.fontWeight;

        case 'interpreter'

            propertyValue = obj.interpreter;

        case 'location'

            propertyValue = obj.location;
            
        case 'normalized'
                    
        	propertyValue = obj.normalized;        

        case 'objecttonotify'

            propertyValue = obj.objectToNotify;

        case 'position'

            propertyValue = obj.position;

        case 'parent'

            propertyValue = obj.parent;    

        case 'space'

            propertyValue = obj.space;   

        case 'visible'

            propertyValue = obj.visible;    

        otherwise

            error([mfilename ':: No property ''' propertyName '''.'])

    end

end
