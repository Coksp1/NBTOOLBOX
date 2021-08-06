function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_plotComb
% 
% Input:
% 
% - obj           : An object of class nb_plotComb
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
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch propertyName

        case 'alpha1'

            propertyValue = obj.alpha1;
        
        case 'alpha2'

            propertyValue = obj.alpha2;    
        
        case 'barwidth'

            propertyValue = obj.barWidth;

        case 'baseline'

            propertyValue = obj.baseline;

        case 'basevalue'

            propertyValue = obj.baseValue; 

        case 'blend'

            propertyValue = obj.blend;      
            
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

        case 'edgelinestyle'

            propertyValue = obj.edgeLineStyle; 

        case 'edgelinewidth'

           propertyValue = obj.edgeLineWidth; 

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

        case 'shadecolor'

            propertyValue = obj.shadeColor;

        case 'shaded'

            propertyValue = obj.shaded;

        case 'side'

            propertyValue = obj.side;

        case 'type'

            propertyValue = obj.type;    

        case 'types'

            propertyValue = obj.types;    

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
