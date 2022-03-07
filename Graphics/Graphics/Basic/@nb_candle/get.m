function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_candle
% 
% Input:
% 
% - obj           : An object of class nb_candle
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

    switch lower(propertyName)

        case 'candlewidth'

            propertyValue = obj.candleWidth;

        case 'cdata'

            propertyValue = obj.cData;

        case 'close'
                    
            propertyValue = obj.close;    
            
        case 'children'

            propertyValue = obj.children; 

        case 'deleteoption'

            propertyValue = obj.deleteOption;    

        case 'direction'

            propertyValue = obj.direction;

        case 'edgecolor'

            propertyValue = obj.edgeColor;

        case 'indicator'
                    
            propertyValue = obj.indicator;

        case 'high'

            propertyValue = obj.high;    
            
        case 'legendinfo'

            propertyValue = obj.legendInfo;    

        case 'linestyle'

            propertyValue = obj.lineStyle;

        case 'linewidth'

            propertyValue = obj.lineWidth;    

        case 'low'
                    
            propertyValue = obj.low;

        case 'open'

            propertyValue = obj.open;     
            
        case 'parent'

            propertyValue = obj.parent;

        case 'shadecolor'

            propertyValue = obj.shadeColor;

        case 'shaded'

            propertyValue = obj.shaded;

        case 'side'

            propertyValue = obj.side;    

        case 'visible'

            propertyValue = obj.visible;    

        case 'xdata'

            propertyValue = obj.xData;

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
