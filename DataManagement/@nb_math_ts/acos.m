function obj = acos(obj)
% Syntax:
%
% obj = acos(obj)
%
% Description:
%
% Inverse cosine, expressed in radians
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
% obj = acos(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = acos(obj.data);
    
end
