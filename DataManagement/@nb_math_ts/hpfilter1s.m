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
% gap   = hpfilter1s(data,3000);
% trend = data-gap;
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for ii = 1:obj.dim2

        % Find first finite observation 
        isFinite = isfinite(obj.data(:,ii,:));
        isFinite = any(isFinite,3);
        first    = find(isFinite,1);
       
        % Need at least 5 observation 
        last = first + 4;

        % Do the one sided filter
        filter = nan(obj.dim1,1,obj.dim3);
        while last <= obj.dim1

            tempData          = obj.data(first:last,ii,:);
            isNaN             = any(isnan(tempData),3);
            tempData          = tempData(~isNaN,1,:);
            tempFilter        = hpfilter(tempData,lambda);
            filter(last,ii,:) = tempFilter(end);

            last = last + 1;

        end

        obj.data(:,ii,:) = filter;

    end

end
