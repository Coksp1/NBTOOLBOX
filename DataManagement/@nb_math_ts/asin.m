function obj =   asin(obj)
% Syntax:
%
% obj = sin(obj)
%
% Description:
%
% Inverse sine, expressed in radians.
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% Output:
% 
% - obj : An object of class nb_math_ts
% 
% Examples:
% 
% obj = sin(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = asin(obj.data);
    
end
