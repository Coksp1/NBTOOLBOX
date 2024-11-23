function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get some otherwise non-accessible properties of the nb_table_ts
% 
% Input:
% 
% - obj           : An object of class nb_table_ts
% 
% - propertyName  : A string with the name of the wanted property. 
% 
% Output:
% 
% - propertyValue : The property value of the given property.
%     
% Examples:
%
% Get the last axes handle of the nb_table_ts object. Be aware that
% all the the axes handles are stored in the figurehandle property
% of the object.
% axeshandle   = obj.get('axeshandle');
%
% Get the handle of all the current figures of the nb_table_ts
% object.
% figurehandle = obj.get('figurehandle');
% 
% See also: 
% nb_figure, nb_axes
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try  
        propertyValue = get@nb_table_data_source(obj,propertyName);
    catch %#ok<CTCH>
        
        switch lower(propertyName)
            case 'manuallysetendtable'
                propertyValue = obj.manuallySetEndTable;            
            case 'manuallysetstarttable'         
                propertyValue = obj.manuallySetStartTable;             
            otherwise
                error([mfilename ':: Either it is not possible to get the property ''' propertyName ''' or you can get it by writing obj.propertyName.'])
        end
        
    end

end
