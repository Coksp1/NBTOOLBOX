function a = or(a,b)
% Syntax:
%
% a = or(a,b)
% 
% Description
%
% The or operator (|)
% 
% Input:
% 
% - a : An object of class nb_objectInExpr
% 
% - b : An object of class nb_objectInExpr
% 
% Output:
% 
% - a : An object of class nb_objectInExpr
% 
% Examples:
% 
% a = a | b;
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_objectInExpr') && isa(b,'nb_objectInExpr')
        a = compare(a,b);
    else
        error([mfilename ':: Undefined function ''or'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
