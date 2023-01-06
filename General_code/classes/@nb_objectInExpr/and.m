function a = and(a,b)
% Syntax:
%
% a = and(a,b)
%
% Description:
%
% The and operator (&).
% 
% Input:
% 
% - a : An object of class nb_objectInExpr
% 
% - b : An object of class nb_objectInExpr
% 
% Output:
% 
% - a : An object of class nb_objectInExpr. 
% 
% Examples:
%
% a = a & b;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_objectInExpr') && isa(b,'nb_objectInExpr')
        a = compare(a,b);
    else
        error([mfilename ':: Undefined function ''or'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
