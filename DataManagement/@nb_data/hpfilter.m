function obj = hpfilter(obj,lambda)
% Syntax:
%
% obj = hpfilter(obj,lambda)
%
% Description:
%
% Do hp-filtering of all the dataseries of the nb_data object. 
% (Returns the gap). Will strip nan values when calculating the 
% filter. 
% 
% Input:
% 
% - obj     : An object of class nb_data
% 
% - lambda  : The lambda of the hp-filter 
% 
% Output:
% 
% - obj     : An nb_data object with the hp-filtered series.
% 
% Examples:
% 
% gap   = hpfilter(data,3000);
% trend = data-gap;
%
% See also:
% hpfilter
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for ii = 1:obj.numberOfVariables

        for jj = 1:obj.numberOfDatasets
        
            tempData               = obj.data(:,ii,jj);
            isNaN                  = isnan(tempData);
            tempData               = tempData(~isNaN);
            obj.data(~isNaN,ii,jj) = hpfilter(tempData,lambda);
            
        end

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@hpfilter,{lambda});
        
    end

end
