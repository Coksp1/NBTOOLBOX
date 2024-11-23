function obj = cumgrowth(obj,stripNaN)
% Syntax:
%
% obj = cumgrowth(obj)
% obj = cumgrowth(obj,stripNaN)
%
% Description:
%
% Calculate cumulative approx growth, using the formula: 
% log(x(t))-log(x(0)) of all the timeseries of the nb_math_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_math_ts
% 
% - stripNaN : Strip nan before calculating the cumulative growth rates.
% 
% Output:
% 
% - obj      : An nb_math_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = cumgrowth(obj);
% obj = cumgrowth(obj,true);
%
% See also:
% growth, icumgrowth
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end
    obj.data = nb_cumgrowth(obj.data,stripNaN);

end
