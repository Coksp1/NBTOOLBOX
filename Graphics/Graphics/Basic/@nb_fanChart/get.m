function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_fanChart
% 
% Input:
% 
% - obj           : An object of class nb_fanChart
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('central');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch lower(propertyName)

        case 'alpha'
            
            propertyValue = obj.alpha;
        
        case 'cdata'

            propertyValue = obj.cData;

        case 'children'

            propertyValue = obj.children;

        case 'central'

            propertyValue = obj.central;

        case 'deleteoption'

            propertyValue = obj.deleteOption;

        case 'legendinfo'

            propertyValue = obj.legendInfo;
            
        case 'linewidth'

            propertyValue = obj.lineWidth;     
            
        case 'method'
            
            propertyValue = obj.method;

        case 'parent'

            propertyValue = obj.parente; 

        case 'percentiles'

            propertyValue = obj.percentiles;

        case 'side'

            propertyValue = obj.side; 
            
        case 'type'

            propertyValue = obj.type;        
            
        case 'xdata'               

            propertyValue = obj.xData;

        case 'ydata'

            propertyValue = obj.yData;

        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
