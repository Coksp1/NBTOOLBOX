function x = uniform_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.uniform_icdf(p,m,k)
%
% Description:
%
% Returns the inverse of the cdf at p of the uniform(m,k) distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : Lower limit of the support.
% 
% - k : Upper limit of the support.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the uniform(m,k) 
%       distribution
%
% See also:
% nb_distribution.uniform_cdf, nb_distribution.uniform_rand, 
% nb_distribution.uniform_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x = p*(k - m) + m;
    
end
