function x = truncated_mean(dist,param,lb,ub)
% Syntax:
%
% x = nb_distribution.truncated_mean(dist,param,lb,ub)
%
% Description:
%
% Mean of the truncated distribution. The calculation is simulation
% based and may vary, except for truncated normal. Set seed to prevent 
% this, or see the mean method of the nb_distribution class.
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
% - x : The mean of the truncated distribution
%
% See also:
% nb_distribution.truncated_mode, nb_distribution.truncated_median, 
% nb_distribution.truncated_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(dist)
        
        case 'normal'
            x = nb_distribution.truncnormal_mean(param{1},param{2},lb,ub);
        otherwise
            draws = nb_distribution.truncated_rand(1000,1,dist,param,lb,ub);
            x     = mean(draws,1);
    end

end
