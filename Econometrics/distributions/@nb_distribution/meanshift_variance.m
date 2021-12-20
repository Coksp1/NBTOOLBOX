function x = meanshift_variance(dist,param,lb,ub,ms)
% Syntax:
%
% x = nb_distribution.meanshift_variance(dist,param,lb,ub,ms)
%
% Description:
%
% Variance of the mean shifted and possibly truncated distribution. 
% The calculation may be simulation based and may vary (if the distribution  
% is truncated). Set seed to prevent this, or see the variance method of  
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
% - x : The variance of the mean shifted and possibly truncated 
%       distribution.
%
% See also:
% nb_distribution.meanshift_mode, nb_distribution.meanshift_median, 
% nb_distribution.meanshift_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(lb) && isempty(ub)
        func  = str2func(['nb_distribution.' dist '_variance']);
        x     = func(param{:});
    else
        switch lower(dist)
            case 'normal'
                x = nb_distribution.truncnormal_variance(param{1},param{2},lb-ms,ub-ms);
            otherwise
                draws = nb_distribution.truncated_rand(1000,1,dist,param,lb-ms,ub-ms);
                x     = var(draws,0,1);
        end
    end

end
