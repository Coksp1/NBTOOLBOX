function obj = sec(obj)
% Syntax:
%
% obj = sec(obj)
%
% Description:
%
% Secant of argument in radians.
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
% obj = sec(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = sec(obj.data);
    
end
