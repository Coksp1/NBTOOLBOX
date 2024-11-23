function obj = exp(obj)
% Syntax:
%
% obj = exp(obj)
%
% Description:
%
% Exponential.
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
% nb_symMatrix.log
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    siz          = size(obj);
    obj.symbols  = exp(obj.symbols);
    obj.symbols  = reshape(obj.symbols,siz);
    
end
