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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch lower(propertyName)

        case 'abrupt'
                    
            propertyValue = obj.abrupt;
        
        case 'accumulate'
                    
            propertyValue = obj.accumulate;    
            
        case 'baseline'

            propertyValue = obj.basline;

        case 'basevalue'

            propertyValue = obj.baseValue;    

        case 'cdata'

            propertyValue = obj.cData;

        case 'children'

            propertyValue = obj.children;

        case 'deleteoption'

            propertyValue = obj.deleteOption;

        case 'facealpha'
                    
            propertyValue = obj.faceAlpha;    
            
        case 'legendinfo'

            propertyValue = obj.legendInfo;    

        case 'linestyle'

            propertyValue = obj.lineStyle;

        case 'linewidth'

            propertyValue = obj.lineWidth;    

        case 'parent'

            propertyValue = obj.parent;

        case 'side'

            propertyValue = obj.side;    

        case 'sumto'

            propertyValue = obj.sumTo;

        case 'type'

            propertyValue = obj.type;    

        case 'visible'

            propertyValue = obj.visible;    

        case 'xdata'

            propertyValue = obj.xData;

        case 'ydata'

            propertyValue = obj.yData;

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
