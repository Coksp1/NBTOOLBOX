function obj = interpolate(obj,method)
% Syntax:
%
% obj = interpolate(obj,method)
%
% Description:
%
% Interpolate the data of the nb_data object. Will discard leading 
% and trailing nan values.
% 
% Input:
% 
% - data   : An nb_ts, nb_cs or nb_data object.
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
% - data : An nb_ts, nb_cs or nb_data object with the interpolated data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_cell')
        error([mfilename ':: The method interpolate is not supported for objects of class nb_cell.'])
    end
    
    if nargin < 2
        method = 'linear';
    end

    obj.data = nb_interpolate(obj.data,method);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@interpolate,{method});
        
    end
    
end
