function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_radar
% 
% Input:
% 
% - obj           : An object of class nb_radar
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

        case 'axescolor'

            propertyValue = obj.axesColor;

        case 'axeslimmax'

            propertyValue = obj.axesLimMax; 

        case 'axeslimmin'

            propertyValue = obj.axesLimMin;    

        case 'axeslinewidth'

            propertyValue = obj.axesLineWidth; 

        case 'cdata'

            propertyValue = obj.cData;
            
        case 'children'
            
            propertyValue = obj.children;

        case 'deleteoption'

            propertyValue = obj.deleteOption;    

        case 'fontcolor'

            propertyValue = obj.fontColor;

        case 'fontname'

            propertyValue = obj.fontName;

        case 'fontsize'

            propertyValue = obj.fontSize;
            
        case 'fontunits'

            propertyValue = obj.fontUnits;    

        case 'fontweight'

            propertyValue = obj.fontWeight;

        case 'isolinecolor'

            propertyValue = obj.isoLineColor;

        case 'isolinestyle'

            propertyValue = obj.isoLineStyle;

        case 'isolinewidth'

            propertyValue = obj.isoLineWidth;

        case 'labels'

            propertyValue = obj.labels;

        case 'legendinfo'

            propertyValue = obj.legendInfo;    

        case 'linestyle'

            propertyValue = obj.lineStyle;

        case 'linewidth'

            propertyValue = obj.lineWidth; 

        case 'location'

            propertyValue = obj.location;

        case 'numberofisolines'

            propertyValue = obj.numberOfIsoLines;    

        case 'parent'

            propertyValue = obj.parent;

        case 'rotate'

            propertyValue = obj.rotate;
            
        case 'scale'
            
            propertyValue = obj.scale;

        case 'side'

            propertyValue = obj.side;
            
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
