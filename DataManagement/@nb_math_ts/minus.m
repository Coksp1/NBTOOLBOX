function obj = minus(a,b)
% Syntax:
%
% obj = minus(a,b)
%
% Description:
%
% Binary subtraction (-).
% 
% Substract all elements of the first input objects data by the 
% second input objects data pair-wise. The objects must be of the 
% same sizes.
%
% It is also possible to substarct data of the obejct by a scalar, 
% or substarct a scalar by the objects data.
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
% obj = a-b;
% obj = 2-b;
% obj = a-2;
%
% See also:
% plus
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_math_ts') && isa(b,'nb_math_ts')

        [a,b] = checkConformity(a,b);

        obj      = a;
        obj.data = a.data - b.data;

    elseif (isa(a,'double') && isa(b,'nb_math_ts'))  

        if isscalar(a)

            obj      = b;
            obj.data = repmat(a,[obj.dim1,obj.dim2, obj.dim3]) - obj.data;

        else
            error([mfilename ':: When the input to ''minus'' is an nb_math_ts object and an double the double must be a scalar.'])
        end

    elseif (isa(a,'nb_math_ts') && isa(b,'double')) 

        if isscalar(b)

            obj      = a;
            obj.data = obj.data - b;

        else
            error([mfilename ':: When the input to ''ldivide'' is an double and an nb_math_ts object the double must be a scalar.'])
        end

    else
        error([mfilename ':: Undefined function ''minus'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
