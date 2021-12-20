function x = beta_mean(m,k)
% Syntax:
%
% x = nb_distribution.beta_mean(m,k)
%
% Description:
%
% Mean of the beta distribution
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
% - x : The mean of the beta distribution
%
% See also:
% nb_distribution.beta_mode, nb_distribution.beta_median, 
% nb_distribution.beta_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = m/(m + k);

end
