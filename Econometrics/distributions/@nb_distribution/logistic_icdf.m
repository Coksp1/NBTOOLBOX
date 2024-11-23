function x = logistic_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.logistic_icdf(p,m,k)
%
% Description:
%
% Returns the inverse of the cdf at p of the logistic distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The location paramter. Mode = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the  
%       logistic(m,k) distribution
%
% See also:
% nb_distribution.logistic_cdf, nb_distribution.logistic_rand, 
% nb_distribution.logistic_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x  = m + k.*log(p./(1 - p));
    
end
