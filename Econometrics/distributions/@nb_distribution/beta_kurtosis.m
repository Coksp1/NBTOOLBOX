function x = beta_kurtosis(m,k)
% Syntax:
%
% x = nb_distribution.beta_kurtosis(m,k)
%
% Description:
%
% Kurtosis of the beta distribution
% 
% Input:
% 
% - m : First shape parameter of the beta distribution. The mean will
%       be given by m/(m + k)
% 
% - k : Second shape parameter of the beta distribution
%
% Output:
% 
% - x : The kurtosis of the beta distribution
%
% See also:
% nb_distribution.beta_median, nb_distribution.beta_mean, 
% nb_distribution.beta_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = 6*((m- k)^2*(m + k + 1) - m*k*(m + k + 2));
    d = m*k*(m + k + 2)*(m + k + 3);
    x = x/d + 3;
    
end
