function f = logistic_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.logistic_cdf(x,m)
%
% Description:
%
% CDF of the logistic distribution
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
% nb_distribution.logistic_pdf, nb_distribution.logistic_rand,
% nb_distribution.logistic_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f = 1 + exp(-(x - m)./k);
    f = 1./f;
    
end
