function obj = sin(obj)
% Syntax:
%
% obj = sin(obj)
%
% Description:
%
% Sine of argument in radians.
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% Output:
% 
% - obj : An object of class nb_math_ts.
% 
% Examples:
% 
% obj = sin(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = sin(obj.data);

end
