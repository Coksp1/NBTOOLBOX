function obj = cumprod(obj,varargin)
% Syntax:
%
% obj = cumprod(obj,varargin)
%
% Description:
%
% Cumulativ product
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% Optional input:
% 
% - Same as for the cumprod function made by MathWorks.
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
% obj = cumprod(obj,1,'reverse');
% obj = cumprod(obj,'omitnan');
% obj = cumprod(obj,1,'reverse','omitnan');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = cumprod(obj.data,varargin{:});

end
