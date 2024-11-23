function x = truncnormal_variance(m,k,lb,ub)
% Syntax:
%
% x = nb_distribution.truncnormal_variance(m,k,lb,ub)
%
% Description:
%
% Variance of the truncated normal distribution
% 
% Input:
% 
% - m : A parameter such that the mean of the normal = m
% 
% - k : A parameter such that the std of the normal = k
%
% Output:
% 
% - x : The variance of the truncated normal distribution
%
% See also:
% nb_distribution.truncnormal_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    beta  = (ub - m)/k;
    alpha = (lb - m)/k;
    if isempty(lb)
        t1 = nb_distribution.normal_pdf(beta,0,1)/nb_distribution.normal_cdf(beta,0,1);
        t  = 1 - beta*t1 - t1^2;
    elseif isempty(ub)
        t = (1 - delta(alpha));
    else
        t1 = (nb_distribution.normal_pdf(alpha,0,1) - nb_distribution.normal_pdf(beta,0,1))/(nb_distribution.normal_cdf(beta,0,1) - nb_distribution.normal_cdf(alpha,0,1));
        t2 = (alpha*nb_distribution.normal_pdf(alpha,0,1) - beta*nb_distribution.normal_pdf(beta,0,1))/(nb_distribution.normal_cdf(beta,0,1) - nb_distribution.normal_cdf(alpha,0,1));
        t  = 1 + t2 - t1^2;
    end
    x = k^2*t;

end

function f = lambda(x)
    f = nb_distribution.normal_pdf(x,0,1)/(1 - nb_distribution.normal_cdf(x,0,1));
end

function f = delta(x)
    f = lambda(x)*(lambda(x) - x);
end
