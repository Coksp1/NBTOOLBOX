function f = gamma_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.gamma_pdf(x,m,k)
%
% Description:
%
% PDF of the gamma distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.gamma_cdf, nb_distribution.gamma_rand, 
% nb_distribution.gamma_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f      = x.^(m-1).*exp(-(x/k));
    div    = k.^m.*gamma(m);
    f      = f./div;
    f(x<0) = zeros;
    if any(~isfinite(f))
        
        ind1 = ~isfinite(f);
        ind2 = not(x/k == 0 & m < 1 & k > 0);
        if any(ind1 | ind2)
            % Numerical issues, so we need to use MATLAB version
            f(ind1 | ind2) = gampdf(x(ind1 | ind2),m,k);
        end
        
    end
     
end
