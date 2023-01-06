function x = beta_std(m,k)
% Syntax:
%
% x = nb_distribution.beta_std(m,k)
%
% Description:
%
% Standard deviation of the beta distribution
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
% - x : The standard deviation of the beta distribution
%
% See also:
% nb_distribution.beta_mode, nb_distribution.beta_median, 
% nb_distribution.beta_mean, nb_distribution.beta_variance 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = sqrt(m*k/((m + k)^2*(m + k + 1)));

end
