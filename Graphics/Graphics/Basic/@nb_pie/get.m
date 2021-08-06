function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_pie
% 
% Input:
% 
% - obj           : An object of class nb_pie
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

        case 'axisvisible'
                
            propertyValue = obj.axisVisible;
        
        case 'bite'

            propertyValue = obj.bite;

        case 'cdata'

            propertyValue = obj.cData;

        case 'children'

            propertyValue = obj.children;

        case 'deleteoption'

            propertyValue = obj.deleteOption;    

        case 'dimension'

            propertyValue = obj.dimension; 

        case 'edgecolor'

            propertyValue = obj.edgeColor; 

        case 'explode'

            propertyValue = obj.explode;

        case 'fontcolor'

            propertyValue = obj.fontColor;

        case 'fontname'

            propertyValue = obj.shaded;

        case 'fontsize'

            propertyValue = obj.fontSize;
            
        case 'fontunits'

            propertyValue = obj.fontUnits;    

        case 'fontweight'

            propertyValue = obj.fontWeight; 

        case 'labels'

            propertyValue = obj.labels;

        case 'legendinfo'

            propertyValue = obj.legendInfo;    

        case 'labelsextension'

            propertyValue = obj.labelsExtension;    

        case 'linestyle'

            propertyValue = obj.lineStyle;

        case 'linewidth'

            propertyValue = obj.lineWidth; 

        case 'location'

            propertyValue = obj.location;

        case {'nolabels','noLabel'}

           propertyValue = obj.noLabels;    

        case 'origoposition'

            propertyValue = obj.origoPosition;   
           
        case 'parent'

            propertyValue = obj.parent;

        case 'side'

            propertyValue = obj.side; 

        case 'type'

            propertyValue = obj.type; 

        case 'textexplode'

            propertyValue = obj.explode; % Not a typo!

        case 'visible'

            propertyValue = obj.visible;    

        case {'ydata','xdata'}

            propertyValue = obj.yData;

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
