function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property value of a nb_distribution object.
% 
% Type properties(obj) in the command line to get a  list of supported 
% properties, and type help nb_distribution.<propertyName> to get help on a  
% specific property.
% 
% Input:
% 
% - obj           : An object of class nb_distribution
% 
% - propertyName  : A string with the property name 
%
% Output:
% 
% - propertyValue : The return value of the wanted property.
%
% Examples:
% 
% propertyValue = get(obj,'type');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ischar(propertyName)

        switch lower(propertyName)
            
            case 'conditionalvalue'
                
                propertyValue = obj.conditionalValue;
            
            case 'lowerbound'
                
                propertyValue = obj.lowerBound;
                
            case 'meanshift'
                
                propertyValue = obj.meanShift;
            
            case 'name'
                
                propertyValue = obj.name;
            
            case 'type'

                propertyValue = obj.type;
                
            case 'upperbound'
                
                propertyValue = obj.upperBound;

            otherwise

                error([mfilename ':: The class nb_distribution has no property ''' propertyName ''' or you have no access to get it.'])

        end
        
    else
        error([mfilename ':: The propertyName input must be a string.'])
    end
    
end
