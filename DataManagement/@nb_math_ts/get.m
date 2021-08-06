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
% - obj          : An object
% 
% - propertyName : 
% 
%     > 'data'        : The datz of the object as a double
%     > 'dim1'        : Size of the first dimension
%     > 'dim2'        : Size of the second dimension
% 	  > 'dim3'        : Size of the third dimension
% 	  > 'endDate'     : The end date of the object as
%                       string
%     > 'startDate'   : The start date of the object as
%                       string
% 
% Output:
% 
% The property value of the object for the given property name
%                       
% Examples:
% 
% dataAsDouble = get(obj,'data');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(propertyName)

        case 'data'

            propertyValue = obj.data;

        case 'dim1'

            propertyValue = obj.dim1; 

        case 'dim2'

            propertyValue = obj.dim2;

        case 'dim3'

            propertyValue = obj.dim3;

        case 'enddate'

            propertyValue = obj.endDate.toString();

        case 'startdate'

            propertyValue = obj.startDate.toString();

        otherwise

            error([mfilename ':: Bad property ' propertyName])

    end

end
