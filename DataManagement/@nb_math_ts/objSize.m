function varargout = objSize(obj,dim)
% Syntax:
%
% varargout = objSize(obj,dim)
%
% Description:
%
% Return the size(s) of the object
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% - dim       : > 1 : Size of the first dimension
%               > 2 : Size of the second dimension
%               > 3 : Size of the third dimension
% 
% Output:
% 
% - varargout : > dim1 : Size of the first dimension
%               > dim2 : Size of the second dimension
%               > dim3 : Size of the third dimension
%
%               See the examples below.
% 
% Examples:
% 
% dim = objSize(obj) 
% 
%     Where dim is 1 x 2 double where the first element
%     is the size of the first dimension and the second element is 
%     the size of the second dimension
% 
% [dim1, dim2] = objSize(obj)
% 
% [dim1, dim2, dim3] = objSize(obj)
% 
% dim1 = objSize(obj,1)
% 
% dim2 = objSize(obj,2)
% 
% dim3 = objSize(obj,3)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 0;
    end

    if dim == 0

        [varargout{1:nargout}] = size(obj.data);

    else

        varargout{1} = size(obj.data,dim);

    end

end
