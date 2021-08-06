function obj = sqrt(obj)
% Syntax:
%
% obj = sqrt(obj)
%
% Description:
%
% Square root.
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
% nb_symMatrix.power
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen
    
    siz          = size(obj);
    obj.symbols  = sqrt(obj.symbols);
    obj.symbols  = reshape(obj.symbols,siz);

end
