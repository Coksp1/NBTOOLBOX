function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property value of a nb_copula object.
% 
% Type properties(obj) in the command line to get a  list of supported 
% properties, and type help nb_copula.<propertyName> to get help on a  
% specific property.
% 
% Input:
% 
% - obj           : An object of class nb_copula
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(propertyName)

        switch lower(propertyName)
            
            case 'distributions'
                
                propertyValue = obj.distributions;
            
            case 'sigma'
                
                propertyValue = obj.sigma;
            
            case 'type'

                propertyValue = obj.type;
                
            otherwise

                error([mfilename ':: The class nb_copula has no property ''' propertyName ''' or you have no access to get it.'])

        end
        
    else
        error([mfilename ':: The propertyName input must be a string.'])
    end
    
end
