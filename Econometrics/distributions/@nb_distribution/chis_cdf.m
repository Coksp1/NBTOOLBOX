function f = chis_cdf(x,m)
% Syntax:
%
% f = nb_distribution.chis_cdf(x,m)
%
% Description:
%
% CDF of the chi squared distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : A parameter such that the mean is m
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.chis_pdf, nb_distribution.chis_rand,
% nb_distribution.chis_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    f      = gammainc(x/2,m*0.5);
    f(x<0) = zeros;
    
end
