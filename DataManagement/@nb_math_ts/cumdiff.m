function obj = cumdiff(obj,stripNaN)
% Syntax:
%
% obj = cumdiff(obj)
% obj = cumdiff(obj,stripNaN)
%
% Description:
%
% Calculate diff, using the formula: x(t)-x(0) of all the timeseries of 
% the nb_math_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_math_ts
% 
% - stripNaN : Strip nan before calculating the cumulative diff.
% 
% Output:
% 
% - obj      : An nb_math_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = cumdiff(obj);
% obj = cumdiff(obj,true);
%
% See also:
% diff, icumdiff
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end
    obj.data = nb_cumdiff(obj.data,stripNaN);

end
