function obj = mtimes(a,b)
% Syntax:
%
% obj = power(a,b)
%
% Description:
%  
% Matrix multiplication (*).
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
% obj = 2*b;
% obj = a*2;
%
% See also:
% times
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if (isa(a,'double') && isa(b,'nb_objectInExpr'))  
        obj = a;
    elseif (isa(a,'nb_objectInExpr') && isa(b,'double')) 
        obj = b;
    else
        error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(a) ''' and ''' class(b) '''. '...
                             '(Remeber that the * operator is the matrix multiplication and not elementwise multiplication (.*))'])
    end

end
