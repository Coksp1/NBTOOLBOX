function x = fgamma_skewness(~,k)
% Syntax:
%
% x = nb_distribution.fgamma_skewness(m,k)
%
% Description:
%
% Skewness of the flipped gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k : A parameter such that the variance of the flipped gamma = m*(k^2)
%
% Output:
% 
% - x : The skewness of the flipped gamma distribution
%
% See also:
% nb_distribution.fgamma_median, nb_distribution.fgamma_mean, 
% nb_distribution.fgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = 2/sqrt(k);

end
