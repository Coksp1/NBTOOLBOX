function d = cov(obj,varargin)
% Syntax:
%
% obj = cov(obj)
%
% Description:
%
% Calculate the covariance of the timeseries stored in a nb_math_ts 
% object
% 
% Input:
% 
% obj : An object of class nb_math_ts
% 
% Output:
% 
% d : A double with the wanted covariances
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d = nan(obj.dim2,obj.dim2,obj.dim3);
    for ii = 1:obj.dim3

        % Calculate the covariance
        isNaN     = any(isnan(obj.data(:,:,ii)),2);
        covValues = cov(obj.data(~isNaN,:,ii));

        % Add it to the output as a new page
        d(:,:,ii) = covValues;

    end

end
