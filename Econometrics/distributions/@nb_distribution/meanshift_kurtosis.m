function x = meanshift_kurtosis(dist,param,lb,ub,ms)
% Syntax:
%
% x = nb_distribution.meanshift_kurtosis(dist,param,lb,ub,ms)
%
% Description:
%
% Kurtosis of the mean shifted and possibly truncated distribution. 
% The calculation may be simulation based and may vary (if the distribution  
% is truncated). Set seed to prevent this, or see the kurtosis method of  
% the nb_distribution class.
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
% - x : The kurtosis of the truncated distribution
%
% See also:
% nb_distribution.meanshift_median, nb_distribution.meanshift_mean, 
% nb_distribution.meanshift_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Some distribution may have a close form solution here, and
    % at some point I may want to add those!
    if isempty(lb) && isempty(ub)
        func  = str2func(['nb_distribution.' dist '_kurtosis']);
        x     = func(param{:});
    else
        draws = nb_distribution.truncated_rand(1000,1,dist,param,lb-ms,ub-ms);
        x     = kurtosis(draws,0,1);
    end
                   
end
