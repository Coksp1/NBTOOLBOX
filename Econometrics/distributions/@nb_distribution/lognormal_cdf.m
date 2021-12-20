function f = lognormal_cdf(x,m,k)
% Syntax:
%
% f = nb_distribution.lognormal_cdf(x,m,k)
%
% Description:
%
% CDF of the lognormal distribution
% 
% Input:
% 
% - x : The point to evaluate the cdf, as a double
%
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.lognormal_pdf, nb_distribution.lognormal_rand,
% nb_distribution.lognormal_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [r,c,p] = size(x);
    s       = r*c*p;
    x       = reshape (x, 1, s);
    f       = zeros (1,s);
    ind     = isnan(x);
    if any(ind)
        f(ind) = nan;
    end

    ind = x == inf;
    if any(ind)
        f(ind) = ones;
    end
    
    ind = x > 0;
    if any(ind)
        f(ind) = 0.5 + 0.5*erf( (log(x(ind)) - m)/(sqrt(2)*k) );
    end

    f = reshape(f,[r,c,p]);

end
