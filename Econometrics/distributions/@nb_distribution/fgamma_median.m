function x = fgamma_median(m,k)
% Syntax:
%
% x = nb_distribution.fgamma_median(m,k)
%
% Description:
%
% Median of the flipped gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k : A parameter such that the variance of the flipped gamma = m*(k^2)
%
% Output:
% 
% - x : The median of the flipped gamma distribution
%
% See also:
% nb_distribution.fgamma_mode, nb_distribution.fgamma_mean, 
% nb_distribution.fgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = nb_distribution.fgamma_icdf(0.5,m,k);

end
