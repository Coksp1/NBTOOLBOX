function obj = hpfilter(obj,lambda,perc,fcstLen)
% Syntax:
%
% obj = hpfilter(obj,lambda)
% obj = hpfilter(obj,lambda,perc,fcstLen)
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
% - perc    : Set to true to calculate the gap as (gap/trend)*100.
%
% - fcstLen : The forecast length. Extrapolates the original series
%             using the average of the last 4 periods. Default is 0.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        fcstLen = 0;
        if nargin < 3
            perc = false;
        end
    end

    obj.data = hpfilter(obj.data,lambda,perc,fcstLen);

end
