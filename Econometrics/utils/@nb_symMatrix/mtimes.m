function obj = mtimes(obj,another)
% Syntax:
%
% obj = mtimes(obj,another)
%
% Description:
%
% Times operator (*), which is the same as using .*.
% 
% Input:
% 
% - obj     : A nb_symMatrix object or double.
%
% - another : A nb_symMatrix object or double.
% 
% Output:
% 
% - obj     : A nb_symMatrix object.
%
% See also:
% nb_symMatrix.times
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = times(obj,another);

end
