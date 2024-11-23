function obj = realpow(a,b)
% Syntax:
%
% obj = realpow(a,b)
%
% Description:
% 
% Real power.
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
% See also:
% mpower, power
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
        error([mfilename ':: Undefined function ''power'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
