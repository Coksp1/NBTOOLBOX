function obj = cumsum(obj,varargin)
% Syntax:
%
% obj = cumsum(obj,varargin)
%
% Description:
%
% Cumulativ sum
% 
% Input:
% 
% - obj : An object of class nb_math_ts
%
% Optional input:
% 
% - Same as for the cumsum function made by MathWorks.
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
% obj = cumsum(obj,1,'reverse');
% obj = cumsum(obj,'omitnan');
% obj = cumsum(obj,1,'reverse','omitnan');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = cumsum(obj.data,varargin{:});

end
