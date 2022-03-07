function data = nb_interpolate(data,method)
% Syntax:
%
% data = nb_interpolate(data)
%
% Description:
%
% Interpolate the data given as a double. Will discard leading and
% trailing nan values.
% 
% Input:
% 
% - data   : A double
%
% - method : 
%
%   > 'nearest'  : Nearest neighbor interpolation
%   > 'linear'   : Linear interpolation. Default
%   > 'spline'   : Piecewise cubic spline interpolation (SPLINE)
%   > 'pchip'    : Shape-preserving piecewise cubic interpolation
%   > 'cubic'    : Same as 'pchip'
%   > 'v5cubic'  : The cubic interpolation from MATLAB 5, which 
%                  does not extrapolate and uses 'spline' if X is 
%                  not equally spaced.
% 
% Output:
% 
% - data : A double
%
% See also:
% interp1
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        method = 'linear';
    end

    for ii = 1:size(data,2)
        
        for jj = 1:size(data,3)
            
            temp  = data(:,ii,jj);
            isNaN = isnan(temp);
            first = find(~isNaN,1);
            last  = find(~isNaN,1,'last');
            if first ~= last
                allX  = first:last;
                x     = find(~isNaN(allX));
                temp  = temp(first - 1 + x);

                % Do the interpolation
                tempX = x(1):x(end);
                data(first:last,ii,jj) = interp1(x,temp,tempX',method);
            end
            
        end
        
        
    end

end
