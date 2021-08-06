function x = hist_icdf(p,a)
% Syntax:
%
% x = nb_distribution.hist_icdf(p,a,b,c,d,e)
%
% Description:
%
% Inverse "CDF" type histogram.
%
% Input:
% 
% - p : A vector of probabilities
%
% - a : The data points, as a nobs x 1 double.
%
% Output:
% 
% - x : A double with the quantile at each element of p of the gamma(m,k) 
%       distribution
%
% See also:
% nb_distribution.hist_cdf, nb_distribution.hist_rand, 
% nb_distribution.hist_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(p);
    p          = p(:);

    if any(abs(2*p-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end
    domain = nb_distribution.hist_domain(a);
    int    = linspace(domain(1), domain(2), 1000);
    [f,c]  = nb_histcounts(a,int);
    f      = bsxfun(@rdivide,f,sum(f,1));
    f      = cumsum(f,1);
    x      = p; 
    for ii = 1:size(p,1)
        ind   = f >= p(ii);
        x(ii) = c(find(ind,1));
    end
    x = reshape(x,[s1,s2,s3]);
    
end
   
