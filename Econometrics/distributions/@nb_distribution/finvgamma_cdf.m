function f = finvgamma_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.finvgamma_cdf(x,m,k)
%
% Description:
%
% CDF of the flipped invgamma distribution
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
% nb_distribution.finvgamma_pdf, nb_distribution.finvgamma_rand,
% nb_distribution.finvgamma_icdf
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    xx        = -x;
    xx(xx<=0) = 0.01;
    f         = 1 - gammainc(m,k./xx);
    f(x>0)    = ones;
    
end