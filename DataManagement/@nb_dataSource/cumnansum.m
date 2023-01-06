function obj = cumnansum(obj)
% Syntax:
%
% obj = cumnansum(obj)
%
% Description:
%
% Cumulativ sum of the series of the object. Ignoring nan 
% values.
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj : An nb_ts, nb_cs or nb_data object where the 'data' property of  
%         the object is now the cumulative sum of the old objects 'data' 
%         property.
% 
% Examples:
%
% obj = cumnansum(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dat = obj.data;
    for ii = 1:obj.numberOfVariables
        
        for jj = 1:obj.numberOfDatasets
            
            dataTemp          = dat(:,ii,jj);
            locNan            = isnan(dataTemp);
            dataToSum         = dataTemp(~locNan);
            summedData        = cumsum(dataToSum,1);
            dataTemp(~locNan) = summedData;
            dat(:,ii,jj)      = dataTemp;
            
        end
        
    end
    obj.data = dat;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cumnansum);
        
    end
    
end

