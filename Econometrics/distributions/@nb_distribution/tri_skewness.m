function x = tri_skewness(m,k,d)
% Syntax:
%
% x = nb_distribution.tri_skewness(m,k,d)
%
% Description:
%
% Skewness of the triangular distribution
% 
% Input:
% 
% - m : Lower bound of the triangular distribution.
%
% - k : Upper bound of the triangular distribution.
%
% - d : Mode of the triangular distribution.
%
% Output:
% 
% - x : The skewness of the triangular distribution
%
% See also:
% nb_distribution.tri_median, nb_distribution.tri_mean, 
% nb_distribution.tri_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = sqrt(2)*(m + k - 2*d)*(2*m - k - d)*(m - 2*k + d);
    d = 5*(m^2 + k^2 + d^2 - m*k - m*d - k*d)^(1.5);
    x = x/d;
    
end
