function x = tri_mean(m,k,d)
% Syntax:
%
% x = nb_distribution.tri_mean(m,k,d)
%
% Description:
%
% Mean of the triangular distribution
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
% - x : The mean of the triangular distribution
%
% See also:
% nb_distribution.tri_mode, nb_distribution.tri_median, 
% nb_distribution.tri_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = (m + k + d)/3;

end
