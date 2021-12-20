function x = truncated_skewness(dist,param,lb,ub)
% Syntax:
%
% x = nb_distribution.truncated_skewness(dist,param,lb,ub)
%
% Description:
%
% Skewness of the truncated distribution. The calculation is simulation
% based and may vary. Set seed to prevent this, or see the skewness method
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
% - x : The skewness of the truncated distribution
%
% See also:
% nb_distribution.truncated_median, nb_distribution.truncated_mean, 
% nb_distribution.truncated_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    draws = nb_distribution.truncated_rand(1000,1,dist,param,lb,ub);
    x     = skewness(draws,0,1);
    
end
