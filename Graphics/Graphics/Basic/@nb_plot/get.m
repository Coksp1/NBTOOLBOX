function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_plot
% 
% Input:
% 
% - obj           : An object of class nb_plot
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

        case 'legendinfo'

            propertyValue = obj.legendInfo;    

        case 'linestyle'

            propertyValue = obj.lineStyle;

        case 'linewidth'

            propertyValue = obj.lineWidth; 

        case 'marker'

            propertyValue = obj.marker;

        case 'markeredgecolor'

            propertyValue = obj.markerEdgeColor;

        case 'markerfacecolor'

            propertyValue = obj.markerFaceColor;

        case 'markersize'

            propertyValue = obj.markerSize;

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
