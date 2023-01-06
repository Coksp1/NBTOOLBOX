function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_scatter
% 
% Input:
% 
% - obj           : An object of class nb_scatter
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('cData');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch propertyName
        
        case 'cdata'

            propertyValue = obj.cData;
            
        case 'deleteoption'

            propertyValue = obj.deleteOption;

        case 'legendinfo'

            propertyValue = obj.legendInfo;
            
        case 'marker'

            propertyValue = obj.marker; 

        case 'markersize'

            propertyValue = obj.markerSize; 

        case 'parent'

            propertyValue = obj.parent;    
            
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
