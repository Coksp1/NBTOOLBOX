function x = f_icdf(p,m,k)
% Syntax:
%
% x = nb_distribution.f_icdf(p,m,k)
%
% Description:
%
% Returns the inverse of the cdf at p of the F(m,k) distribution
% 
% Input:
% 
% - p : A vector of probabilities
%
% - m : First parameter of the distribution. Must be positive.
% 
% - k : Second parameter of the distribution. A parameter such that the 
%       mean of the F-distribution is equal to k/(k-2) for k > 2. Must be
%       positive.
% 
% Output:
% 
% - x : A double with the quantile at each element of p of the F(m,k) 
%       distribution
%
% See also:
% nb_distribution.f_cdf, nb_distribution.f_rand, 
% nb_distribution.f_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if any(abs(2*p(:)-1) > 1)
        error([mfilename ':: a probability should be between 0 and 1'])
    end

    x       = nb_distribution.beta_icdf(p,m/2,k/2);
    x       = x.*k./((1-x).*m);
    x(p==0) = zeros;
    x(p==1) = inf;
    
end
