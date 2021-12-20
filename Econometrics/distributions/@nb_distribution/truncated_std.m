function x = truncated_std(dist,param,lb,ub)
% Syntax:
%
% x = nb_distribution.truncated_std(dist,param,lb,ub)
%
% Description:
%
% Standard deviation of the truncated distribution
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
% - x : The standard deviation of the truncated distribution
%
% See also:
% nb_distribution.truncated_mode, nb_distribution.truncated_median, 
% nb_distribution.truncated_mean, nb_distribution.truncated_variance 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = sqrt(nb_distribution.truncated_variance(dist,param,lb,ub));

end
