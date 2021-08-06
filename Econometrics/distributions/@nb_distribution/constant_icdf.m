function x = constant_icdf(p,m)
% Syntax:
%
% x = nb_distribution.constant_icdf(p,m)
%
% Description:
%
% Returns the inverse of the cdf at p of a constant
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The constant
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the constant(m,k) 
%       distribution
%
% See also:
% nb_distribution.constant_cdf, nb_distribution.constant_rand, 
% nb_distribution.constant_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end
    x = m;
    
end
