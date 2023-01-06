function f = uniform_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.uniform_cdf(x,m,k)
%
% Description:
%
% CDF of the uniform distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.uniform_pdf, nb_distribution.uniform_rand,
% nb_distribution.uniform_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x(x>k) = k; 
    x(x<m) = m;
    f      = (x - m)/(k - m);
    
end
