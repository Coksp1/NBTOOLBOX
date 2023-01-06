function obj = times(a,b)
% Syntax:
%
% obj = times(a,b)
%
% Description:
% 
% Element-wise multiplication (.*)
%
% All elements of the first input objects data is multiplied by the 
% second input objects data pair-wise. The objects must be of the 
% same sizes.
%
% It is also possible to multiply the data of the obejct by a scalar, 
% or multiply a scalar by the objects data, but it is recommended 
% to use mtimes (*) instead. 
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
% obj = a.*b;
% obj = 2.*b;
% obj = a.*2;
%
% See also:
% mtimes
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_math_ts') && isa(b,'nb_math_ts')

        [a,b] = checkConformity(a,b);

        obj      = a;
        obj.data = a.data.*b.data;

    elseif (isa(a,'double') && isa(b,'nb_math_ts'))  

        if isscalar(a)

            obj      = b;
            obj.data = obj.data.*a;

        else
            error([mfilename ':: When the input to ''times'' is an nb_math_ts object and an double the double must be a scalar.'])
        end

    elseif (isa(a,'nb_math_ts') && isa(b,'double')) 

        if isscalar(b)

            obj      = a;
            obj.data = obj.data.*b;

        else
            error([mfilename ':: When the input to ''times'' is an double and an nb_math_ts object the double must be a scalar.'])
        end

    else
        error([mfilename ':: Undefined function ''times'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
