function obj = tan(obj)
% Syntax:
%
% obj = tan(obj)
%
% Description:
%
% Tangent
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
% obj = tan(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = tan(obj.data);
    
end
