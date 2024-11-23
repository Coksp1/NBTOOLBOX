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
% See also:
% nb_math_ts.epcn, nb_math_ts.growth
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin < 2
            lag = 1; 
        end
    end
    obj.data = egrowth(obj.data,lag,stripNaN);

end
