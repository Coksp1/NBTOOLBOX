function obj = mrdivide(a,b)
% Syntax:
%
% obj = mrdivide(a,b)
%
% Description:
%
% Matrix left division (/).
% 
% Input:
% 
% - a   : An object of class nb_objectInExpr or a scalar
% 
% - b   : An object of class nb_objectInExpr or a scalar
% 
% Output:
% 
% - obj : An object of class nb_objectInExpr
% 
% Examples:
%
% obj = 2/obj;
% obj = obj/2;
%
% See also:
% rdivide, ldivide, mldivide
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if (isa(a,'nb_objectInExpr') && isa(b,'double')) 
        obj = a;
    elseif (isa(a,'double') && isa(b,'nb_objectInExpr')) 
        obj = b;
    else
        error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
