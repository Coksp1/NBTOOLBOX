function obj = log(obj)
% Syntax:
%
% obj = log(obj)
%
% Description:
%
% Natural logarithm.
% 
% Input:
% 
% - obj : A nb_symMatrix object.
% 
% Output:
% 
% - obj : A nb_symMatrix object.
%
% See also:
% nb_symMatrix.exp
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    siz          = size(obj);
    obj.symbols  = log(obj.symbols);
    obj.symbols  = reshape(obj.symbols,siz);

end
