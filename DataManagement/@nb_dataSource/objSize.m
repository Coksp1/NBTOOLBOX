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
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% - dim       : - 1 : Number of observations
%               - 2 : Number of variables
%               - 3 : Number of datasets (pages)
% 
% Output:
% 
% - varargout : See the examples below
% 
% Examples:
% 
% dim = objSize(obj) 
% 
%     Where dim is 1 x 2 double where the first element
%     is the number of observations/types and the second element is 
%     the number of variables
% 
% [dim1, dim2] = objSize(obj)
% 
% [dim1, dim2, dim3] = objSize(obj)
% 
% dim1 = objSize(obj,1)
% dim2 = objSize(obj,2)
% dim3 = objSize(obj,3)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 0;
    end

    if dim == 0

        [varargout{1:nargout}] = size(obj.data);

    else

        varargout{1} = size(obj.data,dim);

    end

end
