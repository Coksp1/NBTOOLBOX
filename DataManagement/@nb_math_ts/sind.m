function obj = sind(obj)
% Syntax:
%
% obj = sind(obj)
%
% Description:
%
% Sine, expressed in degrees.
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
% out = sind(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = sind(obj.data);
    
end
