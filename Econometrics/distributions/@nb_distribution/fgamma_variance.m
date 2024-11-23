function x = fgamma_variance(m,k)
% Syntax:
%
% x = nb_distribution.fgamma_variance(m,k)
%
% Description:
%
% Variance of the flipped gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k : A parameter such that the variance of the flipped gamma = m*(k^2)
%
% Output:
% 
% - x : The variance of the flipped gamma distribution
%
% See also:
% nb_distribution.fgamma_mode, nb_distribution.fgamma_median, 
% nb_distribution.fgamma_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = m*(k^2);

end
