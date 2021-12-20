function obj = cumsum(obj,dim)
% Syntax:
%
% obj = cumsum(obj,dim)
%
% Description:
%
% Cumulativ sum
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% - dim : In which dimension the cumulativ sum should be 
%         calculated. Default is the first dimension.
% 
% Output:
% 
% - obj : An object of class nb_math_ts where the data property 
%         of the object is now the cumulative sum of the old 
%         objects data property.
% 
% Examples:
% 
% obj = cumsum(obj,1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 1;
    end

    obj.data = cumsum(obj.data,dim);

end
