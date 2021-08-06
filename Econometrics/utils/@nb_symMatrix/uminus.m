function obj = uminus(obj)
% Syntax:
%
% obj = uminus(obj)
%
% Description:
%
% Uniary minus operator (-) for nb_symMatrix objects.
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
% nb_symMatrix.minus
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen
    
    siz          = size(obj);
    obj.symbols  = uminus(obj.symbols);
    obj.symbols  = reshape(obj.symbols,siz);
    
end
