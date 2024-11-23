function f = hist_pdf(x,a)
% Syntax:
%
% f = nb_distribution.hist_pdf(x,a)
%
% Description:
%
% "PDF" type histogram.
% 
% Input:
% 
% - x : The bin points of the histogram, as a vector double
%
% - a : The data points, as a nobs x 1 double.
% 
% Output:
% 
% - f : The "PDF" at the evaluated points, same size as x.
%
% See also:
% nb_distribution.hist_cdf, nb_distribution.hist_rand, 
% nb_distribution.hist_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    d        = x(2) - x(1);
    interval = x(1) + d/2:d:x(end) + d/10;
    interval = [interval,max(a)];
    f        = nb_histcounts(a,interval);
    f        = bsxfun(@rdivide,f,sum(f,1));
    f        = bsxfun(@rdivide,f,d);
    
end
