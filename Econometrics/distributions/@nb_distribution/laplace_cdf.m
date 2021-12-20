function f = laplace_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.laplace_cdf(x,m)
%
% Description:
%
% CDF of the laplace distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : The location paramter. Median = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.laplace_pdf, nb_distribution.laplace_rand,
% nb_distribution.laplace_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f = 0.5 + 0.5*sign(x - m).*(1 + exp(-abs(x - m)./k));
    
end
