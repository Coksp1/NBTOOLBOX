function a = eq(a,b)
% Syntax:
%
% a = eq(a,b)
%
% Description:
% 
% Test if the two objects are equal elemetswise and return a 
% nb_math_ts object where each element are 1 if true, otherwise 0.
% 
% The objects must have the same dimension
%
% It is also possible to test each element of a object to a scalar
%
% Input:
% 
% - a         : An object of class nb_math_ts or a scalar
% 
% - b         : An object of class nb_math_ts or a scalar
% 
% Output:
% 
% - a         : An nb_math_ts object where each element are 1 if 
%               the different data elemets are equal, otherwise 0.  
%             
% Examples:
%
% obj = a == b;
% obj = 2 == b;
% obj = a == 2;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_math_ts') && isa(b,'nb_math_ts')

        [a,b] = checkConformity(a,b);

        a.data = a.data == b.data;

    elseif isa(a,'nb_math_ts') && isa(b,'double')

        if isscalar(b)

            a.data = a.data == b;

        else

            error([mfilename ':: Undefined function ''eq'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''.'])

        end

    elseif isa(a,'double') && isa(b,'nb_math_ts')

        if isscalar(a)

            b.data = b.data == a;
            a      = b;

        else

            error([mfilename ':: Undefined function ''eq'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''.'])

        end

    else

        error([mfilename ':: Undefined function ''eq'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
