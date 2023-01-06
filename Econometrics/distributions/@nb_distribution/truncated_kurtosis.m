function x = truncated_kurtosis(dist,param,lb,ub)
% Syntax:
%
% x = nb_distribution.truncated_kurtosis(dist,param,lb,ub)
%
% Description:
%
% Kurtosis of the truncated distribution. The calculation is simulation
% based and may vary. Set seed to prevent this, or see the kurtosis method
% of the nb_distribution class.
% 
% Input:
% 
% - dist  : The name of the underlying distribution as a string. Must be 
%           supported by the nb_distribution class.
%
% - param : A cell with the parameters of the selected distribution.
% 
% - lb    : Lower bound of the truncated distribution.
%
% - ub    : Upper bound of the truncated distribution.
%
% Output:
% 
% - x : The kurtosis of the truncated distribution
%
% See also:
% nb_distribution.truncated_median, nb_distribution.truncated_mean, 
% nb_distribution.truncated_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Some distribution may have a close form solution here, and
    % at some point I may want to add those!
    draws = nb_distribution.truncated_rand(1000,1,dist,param,lb,ub);
    x     = kurtosis(draws,0,1);
                   
end
