function a = ne(a,b)
% Syntax:
%
% a = ne(a,b)
%
% Description:
% 
% This method is intended to test if two nb_math_ts objects are not equal. 
% We therefore just return the a object here as the date the objects 
% represent does not change in this case.
%
% Input:
% 
% - a : An object of class nb_objectInExpr or a scalar.
% 
% - b : An object of class nb_objectInExpr or a scalar.
% 
% Output:
% 
% - a : An object of class nb_objectInExpr 
%             
% Examples:
%
% obj = a ~= b;
% obj = 2 ~= b;
% obj = a ~= 2;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_objectInExpr') && isa(b,'nb_objectInExpr')
        a = compare(a,b);
    elseif isa(a,'nb_objectInExpr') && isa(b,'double')
        return
    elseif isa(a,'double') && isa(b,'nb_objectInExpr')
        a = b;
    else
        error([mfilename ':: Undefined function ''ne'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
