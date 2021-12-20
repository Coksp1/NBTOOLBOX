function obj = cumprod(obj,dim)
% Syntax:
%
% obj = cumprod(obj,dim)
%
% Description:
%
% Cumulativ product
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% - dim : In which dimension the cumulativ product should be 
%         calculated. Default is the first dimension.
% 
% Output:
% 
% - obj : An object of class nb_math_ts where the data property 
%         of the object is now the cumulative product of the old 
%         objects data property.
% 
% Examples:
% 
% obj = cumprod(obj,1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 1;
    end

    obj.data = cumprod(obj.data,dim);

end
