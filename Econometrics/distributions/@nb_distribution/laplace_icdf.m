function x = laplace_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.laplace_icdf(p,m,k)
%
% Description:
%
% Returns the inverse of the cdf at p of the laplace distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The location paramter. Median = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the  
%       laplace(m,k) distribution
%
% See also:
% nb_distribution.laplace_cdf, nb_distribution.laplace_rand, 
% nb_distribution.laplace_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x  = m - k*sign(p - 0.5).*ln(1 - 2*abs(p - 0.5));
    
end
