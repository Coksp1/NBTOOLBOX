function f = invgamma_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.invgamma_cdf(x,m,k)
%
% Description:
%
% CDF of the invgamma distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The shape parameter, as a double >0.
% 
% - k : The scale parameter, as a double >0.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.invgamma_pdf, nb_distribution.invgamma_rand,
% nb_distribution.invgamma_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    xx        = x;
    xx(xx<=0) = 0.01;
    f         = gammainc(m,k./xx);
    f(x<0)    = zeros;
    
end
