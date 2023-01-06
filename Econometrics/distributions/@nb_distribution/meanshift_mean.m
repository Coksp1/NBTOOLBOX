function x = meanshift_mean(dist,param,lb,ub,ms)
% Syntax:
%
% x = nb_distribution.meanshift_mean(dist,param,lb,ub,ms)
%
% Description:
%
% Mean of the mean shifted and possibly truncated distribution. 
% The calculation may be simulation based and may vary (if the  
% distribution is truncated). Set seed to prevent this, or see the mean  
% method of the nb_distribution class.
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
% - x : The mean of the mean shifted and possibly truncated distribution. 
%
% See also:
% nb_distribution.meanshift_mode, nb_distribution.meanshift_median, 
% nb_distribution.meanshift_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(lb) && isempty(ub)
        func = str2func(['nb_distribution.' dist '_mean']);
        x    = func(param{:}) + ms;
    else
        switch lower(dist)  
            case 'normal'
                x = nb_distribution.truncnormal_mean(param{1},param{2},lb-ms,ub-ms) + ms;
            otherwise
                draws = nb_distribution.truncated_rand(1000,1,dist,param,lb-ms,ub-ms);
                x     = mean(draws,1) + ms;
        end
    end

end
