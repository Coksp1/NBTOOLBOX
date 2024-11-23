function obj = ldivide(a,b)
% Syntax:
%
% obj = ldivide(a,b)
%
% Description:
%
% Left element-wise division (.\). Same as right element-wise (./)
% division. See rdivide for more.
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
% obj = a.\b;
% obj = 2.\b;
% obj = a.\2;
%
% See also:
% rdivide, mldivide, mrdivide
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_objectInExpr') && isa(b,'nb_objectInExpr')
        obj = compare(a,b);
    elseif (isa(a,'nb_objectInExpr') && isa(b,'double')) 
        obj = a;
    elseif (isa(a,'double') && isa(b,'nb_objectInExpr')) 
        obj = b;
    else
        error([mfilename ':: Undefined function ''ldivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
