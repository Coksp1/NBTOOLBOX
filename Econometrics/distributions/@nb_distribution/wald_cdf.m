function f = wald_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.wald_cdf(x,m,k)
%
% Description:
%
% CDF of the wald distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The first parameter of the wald distribution. Must be a 1x1 double
%       greater than 0. E[X] = m.
% 
% - k : The second parameter of the wald distribution. Must be a 1x1 double
%       greater than 0.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.wald_pdf, nb_distribution.wald_rand,
% nb_distribution.wald_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    z = sqrt(m./x).*(x./k - 1);
    y = -sqrt(m./x).*(x./k + 1);
    f = nb_distribution.normal_cdf(z,0,1) + exp(2*m/k).*nb_distribution.normal_cdf(y,0,1);
    
end
