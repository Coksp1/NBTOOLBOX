function obj =  asec(obj)
% Syntax:
%
% obj = asec(obj)
%
% Description:
%
% Inverse secant, expressed in degrees.
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
% obj = asec(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = asec(obj.data);
end
