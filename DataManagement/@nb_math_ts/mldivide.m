function obj = mldivide(a,b)
% Syntax:
%
% obj = mldivide(a,b)
%
% Description:
%
% Matrix left division (\). Only defined when dividing by a 
% scalar or when a scalar are divide by the object(s data)
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
% obj = 2\obj;
% obj = obj\2;
%
% See also:
% rdivide, ldivide, mrdivide
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if (isa(a,'nb_math_ts') && isa(b,'double')) 

        if isscalar(b)

            obj      = a;
            obj.data = obj.data/b;

        else
            error([mfilename ':: When the input to ''ldivide'' is an double and an nb_math_ts object the double must be a scalar.'])
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
        error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
