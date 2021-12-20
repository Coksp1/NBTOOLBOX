function x = fgamma_mode(m,k)
% Syntax:
%
% x = nb_distribution.fgamma_mode(m,k)
%
% Description:
%
% Mode of the flipped gamma distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k : A parameter such that the variance of the flipped gamma = m*(k^2)
%
% Output:
% 
% - x : The mode of the flipped gamma distribution
%
% See also:
% nb_distribution.fgamma_median, nb_distribution.fgamma_mean, 
% nb_distribution.fgamma_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m >= 1
        x = -(m-1)*k;
    else
        x = 0;
    end

end
