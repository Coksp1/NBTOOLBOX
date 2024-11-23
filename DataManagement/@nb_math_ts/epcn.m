function obj = epcn(obj,lag,stripNaN)
% Syntax:
%
% obj = epcn(obj,lag,stripNaN)
%
% Description:
%
% Calculate exact percentage growth, using the formula: 
% 100*(x(t) - x(t-1))/x(t-1) of all the timeseries of the 
% nb_math_ts object.
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
% obj = epcn(obj);   % period-on-period growth
% obj = epcn(obj,4); % 4-periods growth
% 
% See also:
% nb_math_ts.pcn, , nb_math_ts.egrowth
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin < 2
            lag = 1; 
        end
    end
    obj.data = epcn(obj.data,lag,stripNaN);

end
