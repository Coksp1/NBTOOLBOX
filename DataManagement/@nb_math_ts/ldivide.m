function obj = ldivide(a,b)
% Syntax:
%
% obj = ldivide(a,b)
%
% Description:
%
% Left element-wise division (.\). Same as right element-wise (./)
% division. See rdivide for more.
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
% obj = a.\b;
% obj = 2.\b;
% obj = a.\2;
%
% See also:
% rdivide, mldivide, mrdivide
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_math_ts') && isa(b,'nb_math_ts')

        [a,b] = checkConformity(a,b);

        obj      = a;
        obj.data = a.data./b.data;

    elseif (isa(a,'nb_math_ts') && isa(b,'double')) 

        if isscalar(b)

            obj      = a;
            obj.data = obj.data./b;

        else
            error([mfilename ':: When the input to ''ldivide'' is an nb_math_ts object and an double the double must be a scalar.'])
        end
        
    elseif (isa(a,'double') && isa(b,'nb_math_ts')) 

        if isscalar(a)

            obj      = b;
            data     = repmat(a,[obj.dim1,obj.dim2, obj.dim3]);
            obj.data = data./obj.data;

        else
            error([mfilename ':: When the input to ''ldivide'' is an double and an nb_math_ts object the double must be a scalar.'])
        end

    else
        error([mfilename ':: Undefined function ''ldivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
