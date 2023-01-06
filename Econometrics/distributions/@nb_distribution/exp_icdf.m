function x = exp_icdf(p,m)
% Syntax:
%
% x = nb_distribution.exp_icdf(p,m)
%
% Description:
%
% Returns the inverse of the cdf at p of the exponential distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the F(m,k) 
%       distribution
%
% See also:
% nb_distribution.exp_cdf, nb_distribution.exp_rand, 
% nb_distribution.exp_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x       = -(1/m)*log(1-p);
    x(p==0) = zeros;
    x(p==1) = inf;
    
end
