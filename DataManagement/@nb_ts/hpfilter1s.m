function obj = hpfilter1s(obj,lambda)
% Syntax:
%
% obj = hpfilter1s(obj,lambda)
%
% Description:
%
% Do one-sided hp-filtering of all the dataseries of the nb_ts 
% object. (Returns the gap). Will strip nan values when calculating 
% the filter. 
% 
% Input:
% 
% - obj     : An object of class nb_ts
% 
% - lambda  : The lambda of the hp-filter 
% 
% Output:
% 
% - obj     : An nb_ts object with the hp-filtered timeseries.
% 
% Examples:
% 
% gap   = hpfilter1s(data,3000);
% trend = data-gap;
%
% See also:
% hpfilter
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = hpfilter1s(obj.data,lambda);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@hpfilter1s,{lambda});
        
    end

end
