function d = corr(obj,varargin)
% Syntax:
%
% d = corr(obj)
%
% Description:
%
% Calculate the correlation of the timeseries stored in the 
% nb_math_ts object
% 
% Input:
% 
% obj : An object of class nb_math_ts
% 
% Output:
% 
% d : A double with the wanted correlation
% 
% Examples:
% 
% corrMatrix = corr(obj)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d = nan(obj.dim2,obj.dim2,obj.dim3);
    for ii = 1:obj.dim3

        % Calculate the correlation
        isNaN      = any(isnan(obj.data(:,:,ii)),2);
        corrValues = corr(obj.data(~isNaN,:,ii));

        % Add it to the output as a new page
        d(:,:,ii) = corrValues;

    end

end
