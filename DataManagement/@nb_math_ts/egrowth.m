function obj = egrowth(obj,lag,stripNaN)
% Syntax:
%
% obj = egrowth(obj,lag,stripNaN)
%
% Description:
%
% Calculate exact growth, using the formula: (x(t) - x(t-1))/x(t-1)
% of all the timeseries of the nb_math_ts object.
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% - lag       : The number of lags in the growth formula, default is 1.
% 
% - stripNaN  : Stip nan before calculating the growth rates.
% 
% Output:
% 
% - obj  : An nb_math_ts object with the calculated timeseries 
%          stored.
% 
% Examples:
%
% obj = egrowth(obj);
% obj = egrowth(obj,4);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin < 2
            lag = 1; 
        end
    end

    if stripNaN
        % Strip nan values before calculating the growth
        isNaN = isnan(obj.data);
        for vv = 1:obj.dim2
            for pp = 1:obj.dim3
                din     = obj.data(~isNaN(:,vv,pp),vv,pp);
                din     = log(din);
                [~,c,p] = size(din); 
                dout     = cat(1,nan(lag,c,p),(din(lag + 1:end,:,:)-din(1:end - lag,:,:))./din(1:end - lag,:,:));
                obj.data(~isNaN(:,vv,pp),vv,pp) = dout;
            end
        end
    else
        din      = obj.data;
        [~,c,p]  = size(din); 
        dout     = cat(1,nan(lag,c,p),(din(lag + 1:end,:,:)-din(1:end - lag,:,:))./din(1:end - lag,:,:));
        obj.data = dout;
    end

end
