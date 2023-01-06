function obj = mpower(a,b)
% Syntax:
%
% obj = power(a,b)
%
% Description:
% 
% Element-wise power (.^)
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
% obj = 2^b;
% obj = a^2;
%
% See also:
% power
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if (isa(a,'nb_objectInExpr') && isa(b,'double')) 
        obj = a;
    elseif (isa(a,'double') && isa(b,'nb_objectInExpr')) 
        obj = b;
    else
        error([mfilename ':: Undefined function ''mpower'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
