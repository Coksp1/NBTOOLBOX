function f = f_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.f_cdf(x,m,k)
%
% Description:
%
% CDF of the F(m,k) distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : First parameter of the distribution. Must be positive
% 
% - k : Second parameter of the distribution. A parameter such that the 
%       mean of the F-distribution is equal to k/(k-2) for k > 2. Must be
%       positive.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.f_pdf, nb_distribution.f_rand,
% nb_distribution.f_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x(x<0) = 0;
    term   = m*x./(m*x + k);
    f      = betainc(term,m/2,k/2);
    f(x<0) = zeros;
    
end
