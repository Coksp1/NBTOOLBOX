function x = beta_skewness(m,k)
% Syntax:
%
% x = nb_distribution.beta_skewness(m,k)
%
% Description:
%
% Skewness of the beta distribution
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
% - x : The skewness of the beta distribution
%
% See also:
% nb_distribution.beta_median, nb_distribution.beta_mean, 
% nb_distribution.beta_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = 2*(k - m)*sqrt(m + k + 1);
    d = (m + k + 2)*sqrt(m*k);
    x = x/d;
    
end
