function x = fgamma_mean(m,k)
% Syntax:
%
% x = nb_distribution.fgamma_mean(m,k)
%
% Description:
%
% Mean of the flipped gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k : A parameter such that the variance of the flipped gamma = m*(k^2)
%
% Output:
% 
% - x : The mean of the flipped gamma distribution
%
% See also:
% nb_distribution.fgamma_mode, nb_distribution.fgamma_median, 
% nb_distribution.fgamma_variance
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = -m*k;

end
