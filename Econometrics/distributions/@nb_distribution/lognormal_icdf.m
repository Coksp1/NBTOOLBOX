function x = lognormal_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.lognormal_icdf(p,m,k)
%
% Description:
%
% Inverse CDF of the lognormal density
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : A parameter such that the mean of the lognormal is exp((m+k^2)/2)
% 
% - k : A parameter such that the mean of the lognormal is k exp((m+k^2)/2)
%
% Output:
% 
% - x : The inverse CDF at the evaluated probabilities, same size as p.
%
% See also:
% nb_distribution.lognormal_pdf, nb_distribution.lognormal_rand,
% nb_distribution.lognormal_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    logx = -sqrt(2).*erfcinv(2*p);
    x    = exp(k*logx + m);
 
end
