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
%     - 'data'                 : The data of the object as a double
%     - 'dataNames'            : Name of the object datasets, as 
%                                cellstr array
%     - 'endDate'              : The end date of the object as 
%                                nb_date
%     - 'frequency'            : The frequency of the data, as 
%                                double
%     - 'numberOfDatasets'     : Number of datasets (pages) of the 
%                                object. Size of the third 
%                                dimension
%     - 'numberOfObservations' : Number of observations of the 
%                                object. Size of the first 
%                                dimension
%     - 'numberOfVariables'    : Number of variables of the object.
%                                Size of the second dimension
%     - 'startDate'            : The start date of the object as 
%                                nb_date
%     - 'variables'            : The variables of the object, given 
%                                as a cellstr array
%
%     - 'links'                : A structure of the data source
%                                links.
%
%     - 'sorted'               : true or false
%
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(propertyName)

        case 'data'

            propertyValue = obj.data;
            
        case 'datanames'
            
            propertyValue = obj.dataNames;

        case 'enddate'

            propertyValue = obj.endDate;

        case 'frequency'
            
            propertyValue = obj.frequency;
            
        case 'numberofdatasets'

            propertyValue = obj.numberOfDatasets; 

        case 'numberofobservations'

            propertyValue = obj.numberOfObservations;

        case 'numberofvariables'

            propertyValue = obj.numberOfVariables;    

        case 'startdate'

            propertyValue = obj.startDate;

        case 'variables'
            
            propertyValue = obj.variables;
            
        case 'links'
            
            propertyValue = obj.links;
            
        case 'sorted'
            
            propertyValue = obj.sorted;
            
        case 'updateable'
            
            propertyValue = obj.updateable;
            
        otherwise

            error([mfilename ':: Bad property ' propertyName])

    end

end
