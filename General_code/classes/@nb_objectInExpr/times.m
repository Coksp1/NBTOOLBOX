function obj = times(a,b)
% Syntax:
%
% obj = times(a,b)
%
% Description:
% 
% Element-wise multiplication (.*)
% 
% Input:
% 
% - a   : An object of class nb_objectInExpr or a scalar double
% 
% - b   : An object of class nb_objectInExpr or a scalar double
% 
% Output:
% 
% - obj : An object of class nb_objectInExpr
% 
% See also:
% mtimes
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
        error([mfilename ':: Undefined function ''times'' for input ',...
            'arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
