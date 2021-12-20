function a = or(a,b)
% Syntax:
%
% a = or(a,b)
% 
% Description
%
% The or operator (|)
%
% Will test elemetwise the data property of the two input objects
% and return 1 if both elemets are above 1, otherwise will return
% 0.
% 
% Input:
% 
% - a         : An object of class nb_math_ts
% 
% - b         : An object of class nb_math_ts
% 
% Output:
% 
% - a         : An nb_math_ts object where the || operator have 
%               been used for the corresponding elements of the 
%               input objects data and the result are given by the 
%               output objects data property. The data will be a 
%               logical matrix
% 
% Examples:
% 
% a = a | b;
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_math_ts') && isa(b,'nb_math_ts')

        [a,b] = checkConformity(a,b);

        a.data = a.data | b.data;

    else

        error([mfilename ':: Undefined function ''or'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
