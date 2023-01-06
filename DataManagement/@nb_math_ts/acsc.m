function obj = acsc(obj)
% Syntax:
%
% obj = acsc(obj)
%
% Description:
%
% Inverse cosecant, expressed in radians
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
% obj = acsc(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = acsc(obj.data);
    
end
