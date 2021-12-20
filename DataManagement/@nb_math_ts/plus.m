function obj = plus(a,b)
% Syntax:
%
% obj = plus(a,b)
%
% Description:
%
% Binary addition (+).
% 
% Added all elements of the two input objects data pair-wise. 
% The objects must be of the same sizes.
%
% It is also possible to add a scalar to the data of the obejct.
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
% obj = a+b;
% obj = 2+b;
% obj = a+2;
%
% See also:
% minus
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_math_ts') && isa(b,'nb_math_ts')

        [a,b] = checkConformity(a,b);

        obj      = a;
        obj.data = a.data + b.data;

    elseif (isa(a,'double') && isa(b,'nb_math_ts'))  

        if isscalar(a)

            obj      = b;
            obj.data = obj.data + a;

        else
            error([mfilename ':: Undefined function ''plus'' for input arguments of type ''' class(a) ' vector''  and ''' class(b) '''.'])
        end

    elseif (isa(a,'nb_math_ts') && isa(b,'double')) 

        if isscalar(b)

            obj      = a;
            obj.data = obj.data + b;

        else
            error([mfilename ':: Undefined function ''plus'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''.'])
        end

    else
        error([mfilename ':: Undefined function ''plus'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
