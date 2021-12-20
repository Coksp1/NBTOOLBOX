function f = beta_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.beta_cdf(x,m,k)
%
% Description:
%
% CDF of the beta distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : First shape parameter of the beta distribution. The mean will
%       be given by m/(m + k)
% 
% - k : Second shape parameter of the beta distribution
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.beta_pdf, nb_distribution.beta_rand,
% nb_distribution.beta_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x(x>1) = 1; 
    x(x<0) = 0;
    f      = betainc(x,m,k);
    
end
