function obj = mtimes(a,b)
% Syntax:
%
% obj = power(a,b)
%
% Description:
%  
% Matrix multiplication (*) Only defined for multplication with a
% scalar.
%
% Makes it possible to multiply the data of the obejct by a scalar, 
% or multiply a scalar by the objects data.
%
% Input:
% 
% - a         : An object of class nb_math_ts or a scalar
% 
% - b         : An object of class nb_math_ts or a scalar
% 
% Output:
% 
% - obj       : An object of class nb_math_ts with the calculated 
%               data stored
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if (isa(a,'double') && isa(b,'nb_math_ts'))  

        if isscalar(a)

            obj      = b;
            obj.data = obj.data.*a;

        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(a) ' vector''  and ''' class(b) '''. '...
                             '(Remeber that the * operator is the matrix multiplication and not elementwise multiplication (.*))'])
        end

    elseif (isa(a,'nb_math_ts') && isa(b,'double')) 

        if isscalar(b)

            obj      = a;
            obj.data = obj.data.*b;

        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''. '...
                             '(Remeber that the * operator is the matrix multiplication and not elementwise multiplication (.*))'])
        end

    else
        error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(a) ''' and ''' class(b) '''. '...
                             '(Remeber that the * operator is the matrix multiplication and not elementwise multiplication (.*))'])
    end

end
