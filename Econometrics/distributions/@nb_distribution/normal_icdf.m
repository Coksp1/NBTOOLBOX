function x = normal_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.normal_icdf(p,m,k)
%
% Description:
%
% Inverse CDF of the normal density
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The mean of the distribution
% 
% - k : The std of the distribution
%
% Output:
% 
% - x : The inverse CDF at the evaluated probabilities, same size as p.
%
% See also:
% nb_distribution.normal_pdf, nb_distribution.normal_rand,
% nb_distribution.normal_cdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x = m - k.*sqrt(2).*erfcinv(2.*p);
    
end
