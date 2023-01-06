function x = tri_variance(m,k,d)
% Syntax:
%
% x = nb_distribution.tri_variance(m,k,d)
%
% Description:
%
% Variance of the triangular distribution
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
% - x : The variance of the triangular distribution
%
% See also:
% nb_distribution.tri_mode, nb_distribution.tri_median, 
% nb_distribution.tri_mean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = (m^2 + k^2 + d^2 - m*k - m*d - k*d)/18;

end
