function f = gamma_lpdf(x,m,k)
% Syntax:
%
% f = nb_distribution.gamma_lpdf(x,m,k)
%
% Description:
%
% Log of the PDF of the gamma distribution (using the natural logarithm).
% 
% Input:
% 
% - x : The point to evaluate the log pdf, as a double
%
% - m : A parameter such that the mean of the gamma = m*k
% 
% - k : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - f : The log of the PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.gamma_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    lf     = (m-1).*log(x) - (x/k);
    ldiv   = m.*log(k) + gammaln(m);
    f      = lf - ldiv;
    f(x<0) = -inf;
    if any(~isfinite(f(x>=0)))
        
        ind1 = ~isfinite(f);
        ind2 = not(x/k == 0 & m < 1 & k > 0);
        ind3 = x>=0;
        ind  = (ind1 | ind2) & ind3;
        if any(ind)
            % Numerical issues, so we need to use MATLAB version
            f(ind) = log(gampdf(x(ind),m,k));
        end
        
    end
     
end
