function propertyValue = get(obj,propertyName)
% Syntax:
%
% propertyValue = get(obj,propertyName)
%
% Description:
%
% Get the properties of the object
% 
% Input:
% 
% - obj          : An object of class nb_ts
% 
% - propertyName : Name of the property you want to get:
% 
%     - 'cdata'                : The data of the object as a cell.
%     - 'data'                 : The data of the object as a double
%     - 'dataNames'            : Name of the object datasets, as 
%                                cellstr array
%     - 'numberOfDatasets'     : Number of datasets (pages) of the 
%                                object. Size of the third 
%                                dimension
%     - 'links'                : A structure of the data source
%                                links.
%     - 'updateable'           : 1 if updateable, 0 otherwise.
% 
% Output:
% 
% propertyValue : The property value of the object for the wanted 
%                 property
%                       
% Examples:
% 
% dataAsDouble = get(obj,'data');
% variables    = get(obj,'variables')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch lower(propertyName)
        
        case 'cdata'
            
            propertyValue = obj.cdata;

        case 'data'

            propertyValue = obj.data;
            
        case 'datanames'
            
            propertyValue = obj.dataNames;

        case 'numberofdatasets'

            propertyValue = obj.numberOfDatasets; 
  
        case 'links'
            
            propertyValue = obj.links;
               
        case 'updateable'
            
            propertyValue = obj.updateable;
            
        otherwise

            error([mfilename ':: Bad property ' propertyName])

    end

end
