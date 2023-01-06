function obj = csc(obj)
% Syntax:
%
% obj = csc(obj)
%
% Description:
%
% Cosecant of argument in radians.
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
% obj = csc(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = csc(obj.data);
    
end
