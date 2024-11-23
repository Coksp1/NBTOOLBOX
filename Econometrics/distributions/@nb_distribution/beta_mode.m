function x = beta_mode(m,k)
% Syntax:
%
% x = nb_distribution.beta_mode(m,k)
%
% Description:
%
% Mode of the beta distribution. When the m,k <= 1 the distribution get
% bimodal, so mode can be either 0 or 1, so nan is returned
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
% - x : The mode of the beta distribution
%
% See also:
% nb_distribution.beta_median, nb_distribution.beta_mean, 
% nb_distribution.beta_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if k > 1 && m > 1
        x = m - 1;
        d = m + k - 2;
        x = x/d;
    elseif k < 1 && m < 1
        x = nan; % bimodal
    elseif m < k
        x = 0;
    else
        x = 1;
    end

end
