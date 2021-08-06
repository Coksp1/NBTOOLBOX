function obj = hpfilter(obj,lambda)
% Syntax:
%
% obj = hpfilter(obj,lambda)
%
% Description:
%
% Do hp-filtering of all the dataseries of the nb_math_ts object. 
% (Returns the gap). Will strip nan values when calculating the 
% filter. 
% 
% Input:
% 
% - obj     : An object of class nb_math_ts
% 
% - lambda  : The lambda of the hp-filter 
% 
% Output:
% 
% - obj     : An nb_math_ts object with the hp-filtered timeseries.
% 
% Examples:
% 
% gap   = hpfilter(data,3000);
% trend = data-gap;
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for ii = 1:obj.dim2

        tempData = obj.data(:,ii,:);
        isNaN    = any(isnan(tempData),3);
        tempData = tempData(~isNaN,1,:);
        if ~isempty(tempData)
            obj.data(~isNaN,ii,:) = hpfilter(tempData,lambda);
        end
        
    end

end
