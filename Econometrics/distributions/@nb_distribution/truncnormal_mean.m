function x = truncnormal_mean(m,k,lb,ub)
% Syntax:
%
% x = nb_distribution.truncnormal_mean(m,k,lb,ub)
%
% Description:
%
% Mean of the truncated normal distribution
% 
% Input:
% 
% - m  : A parameter such that the mean of the normal is m
% 
% - k  : A parameter such that the std of the normal is k
%
% - lb : Lower bound
%
% - ub : Upper bound
%
% Output:
% 
% - x : The mean of the truncated normal distribution
%
% See also:
% nb_distribution.truncnormal_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    beta  = (ub - m)/k;
    alpha = (lb - m)/k;
    if isempty(lb)
        t1 = nb_distribution.normal_pdf(beta,0,1)/nb_distribution.normal_cdf(beta,0,1);
        x  = m - k*t1;
    elseif isempty(ub)
        x  = m + k.*lambda(alpha);
    else
        t1 = (nb_distribution.normal_pdf(alpha,0,1) - nb_distribution.normal_pdf(beta,0,1))/(nb_distribution.normal_cdf(beta,0,1) - nb_distribution.normal_cdf(alpha,0,1));
        x  = m + k*t1;
    end
    

end

function f = lambda(x)
    f = nb_distribution.normal_pdf(x,0,1)/(1 - nb_distribution.normal_cdf(x,0,1));
end
