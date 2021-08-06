function x = beta_median(m,k)
% Syntax:
%
% x = nb_distribution.beta_median(m,k)
%
% Description:
%
% Median of the beta distribution
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
% - x : The median of the beta distribution
%
% See also:
% nb_distribution.beta_mode, nb_distribution.beta_mean, 
% nb_distribution.beta_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = betaincinv(1/2,m,k);

end
