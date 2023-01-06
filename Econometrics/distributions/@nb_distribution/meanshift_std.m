function x = meanshift_std(dist,param,lb,ub,ms)
% Syntax:
%
% x = nb_distribution.meanshift_std(dist,param,lb,ub,ms)
%
% Description:
%
% Standard deviation of the mean shifted and possibly truncated 
% distribution. 
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
% - ms    : Mean shift parameter.
%
% Output:
% 
% - x : The standard deviation of the mean shifted and possibly truncated 
%       distribution. 
%
% See also:
% nb_distribution.meanshift_mode, nb_distribution.meanshift_median, 
% nb_distribution.meanshift_mean, nb_distribution.meanshift_variance 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = sqrt(nb_distribution.meanshift_variance(dist,param,lb,ub,ms));

end
