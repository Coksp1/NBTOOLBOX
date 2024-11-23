function obj = atan(obj)
% Syntax:
%
% obj = atan(obj)
%
% Description:
%
% Inverse tangent, expressed in radians.
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
% obj = atan(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = atan(obj.data);
end
