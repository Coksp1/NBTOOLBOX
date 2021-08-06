function obj = mpower(obj,another)
% Syntax:
%
% obj = mpower(obj,another)
%
% Description:
%
% Power operator (^), which is the same as using .^.
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
% nb_symMatrix.power
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = power(obj,another);

end
