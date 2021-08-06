function f = lognormal_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.lognormal_pdf(x,m,k)
%
% Description:
%
% PDF of the lognormal distribution
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
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.lognormal_cdf, nb_distribution.lognormal_rand,
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

    ind = x > 0;
    if any(ind)
        f(ind) = nb_distribution.normal_pdf(log(x(ind)),log(m),k)./x(ind);
    end

    f = reshape(f,[r,c,p]);

end
