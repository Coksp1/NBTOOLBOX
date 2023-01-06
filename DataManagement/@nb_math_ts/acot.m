function obj = acot(obj)
% Syntax:
%
% obj = acot(obj)
%
% Description:
%
% Cotangent
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
% obj = acot(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = acot(obj.data);
    
end
