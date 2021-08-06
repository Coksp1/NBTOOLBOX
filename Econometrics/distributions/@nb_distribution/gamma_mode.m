function x = gamma_mode(m,k)
% Syntax:
%
% x = nb_distribution.gamma_mode(m,k)
%
% Description:
%
% Mode of the gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - x : The mode of the gamma distribution
%
% See also:
% nb_distribution.gamma_median, nb_distribution.gamma_mean, 
% nb_distribution.gamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m >= 1
        x = (m-1)*k;
    else
        x = 0;
    end

end
