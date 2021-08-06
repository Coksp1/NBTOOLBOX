function x = tri_median(m,k,d)
% Syntax:
%
% x = nb_distribution.tri_median(m,k,d)
%
% Description:
%
% Median of the triangular distribution
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
% - x : The median of the triangular distribution
%
% See also:
% nb_distribution.tri_mode, nb_distribution.tri_mean, 
% nb_distribution.tri_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = nb_distribution.tri_icdf(0.5,m,k,d);

end
