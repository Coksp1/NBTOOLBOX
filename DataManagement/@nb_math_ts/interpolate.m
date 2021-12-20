function obj = interpolate(obj,method)
% Syntax:
%
% obj = interpolate(obj,method)
%
% Description:
%
% Interpolate the data of the nb_math_ts object. Will discard leading 
% and trailing nan values.
% 
% Input:
% 
% - data   : A nb_math_ts object.
%
% - method : 
%
%   - 'nearest'  : Nearest neighbor interpolation
%   - 'linear'   : Linear interpolation. Default
%   - 'spline'   : Piecewise cubic spline interpolation (SPLINE)
%   - 'pchip'    : Shape-preserving piecewise cubic interpolation
%   - 'cubic'    : Same as 'pchip'
%   - 'v5cubic'  : The cubic interpolation from MATLAB 5, which 
%                  does not extrapolate and uses 'spline' if X is 
%                  not equally spaced.
% 
% Output:
% 
% - data : A nb_math_ts object with the interpolated data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        method = 'linear';
    end

    obj.data = nb_interpolate(obj.data,method);
     
end
