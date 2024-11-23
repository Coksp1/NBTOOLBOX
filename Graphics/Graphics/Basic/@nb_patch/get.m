function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_patch
% 
% Input:
% 
% - obj           : An object of class nb_patch
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

    switch lower(propertyName)

        case 'cdata'

            propertyValue = obj.cData;

        case 'children'

            propertyValue = obj.children;

        case 'clipping'

            propertyValue = obj.clipping;

        case 'deleteoption'

            propertyValue = obj.deleteOption;    

        case 'direction'

            propertyValue = obj.direction;

        case 'edgecolor'

            propertyValue = obj.edgeColor;

        case 'facealpha'

            propertyValue = obj.faceAlpha;

        case 'facelighting'

            propertyValue = obj.faceLighting; 

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
