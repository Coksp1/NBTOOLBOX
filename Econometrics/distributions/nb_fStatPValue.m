function p = nb_fStatPValue(x,m,k)
% Syntax:
%
% p = nb_fStatPValue(x,m,k)
%
% Description:
%
% P-value of F-statistics.
% 
% Input:
% 
% - x : The point to evaluate the t-statistics at, as a double.
%
% - m : Numerator degree of freedom. Must be positive.
%
% - k : Denominator degree of freedom. Must be positive.
%
% Output:
% 
% - p : P-value of F-statistics, same size as x.
%
% See also:
% nb_distribution.f_pdf, nb_distribution.f_rand,
% nb_distribution.f_icdf, nb_distribution.f_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if (m <= 0 || k <= 0)
        error([mfilename ':: Zero degrees of freedom when trying to evaluate the P-value of the F-statistics.']);
    end
    if any(x < -eps^(1/2))
        error([mfilename ':: Negative F-statistics is not possible.']);
    end

    term          = k/(k + m*x);
    term(term==0) = term(term==0) + 0.0001;
    term(term==1) = term(term==1) - 0.0001;
    p             = betainc(term,.5*k,.5*m);
    
end
