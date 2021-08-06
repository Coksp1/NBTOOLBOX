function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get some otherwise non-accessible properties of the 
% nb_graph_subplot
% 
% Input:
% 
% - obj           : An object of class nb_graph_subplot
% 
% - propertyName  : A string with the name of the wanted property. 
% 
% Output:
% 
% - propertyValue : The property value of the given property.
%     
% Examples:
%
% See also: 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(propertyName)
            
        case 'figurehandle'
            
            propertyValue = obj.figureHandle;
        
        case 'graphmethod'
            
            propertyValue = obj.graphMethod; 
            
        case 'numberofgraphs'
            
            propertyValue = obj.numberOfGraphs;    

        otherwise

            error([mfilename ':: Either it is not possible to get the property ''' propertyName ''' or you can get by writing obj.propertyName.'])

    end

end
