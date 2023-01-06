function obj = minus(a,b)
% Syntax:
%
% obj = minus(a,b)
%
% Description:
%
% Binary subtraction (-).
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
% obj = a-b;
% obj = 2-b;
% obj = a-2;
%
% See also:
% plus
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_objectInExpr') && isa(b,'nb_objectInExpr')
        obj = compare(a,b);
    elseif (isa(a,'double') && isa(b,'nb_objectInExpr'))  
        obj = b;
    elseif (isa(a,'nb_objectInExpr') && isa(b,'double')) 
        obj = a;
    else
        error([mfilename ':: Undefined function ''minus'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
