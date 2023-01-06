function obj = atand(obj)
% Syntax:
%
% obj = atand(obj)
%
% Description:
%
% Inverse tangent, expressed in degrees.
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
% out = atand(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = atand(obj.data);
    
end
