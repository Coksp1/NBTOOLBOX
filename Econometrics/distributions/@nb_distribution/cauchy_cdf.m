function f = cauchy_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.cauchy_cdf(x,m)
%
% Description:
%
% CDF of the cauchy distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The location paramter. Mode = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.cauchy_pdf, nb_distribution.cauchy_rand,
% nb_distribution.cauchy_icdf
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    f = (1/pi).*atan((x - m)./k) + 0.5;
    
end
