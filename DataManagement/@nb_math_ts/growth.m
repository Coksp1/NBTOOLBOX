function obj = growth(obj,lag,stripNaN)
% Syntax:
%
% obj = growth(obj)
% obj = growth(obj,lag,stripNaN)
%
% Description:
%
% Calculate approx growth, using the formula: log(x(t))-log(x(t-1)
% of all the timeseries of the nb_math_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_math_ts
% 
% - lag      : The number of lags in the approx. growth formula, 
%              default is 1.
% 
% - stripNaN : Stip nan before calculating the growth rates.
% 
% Output:
% 
% - obj  : An nb_math_ts object with the calculated timeseries 
%          stored.
% 
% Examples:
%
% obj = growth(obj);
% obj = growth(obj,4);
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
    
    obj.data = growth(obj.data,lag,stripNaN);

end
