function obj = sinh(obj)
% Syntax:
%
% obj = sinh(obj)
%
% Description:
%
% Hyperbolic sine.
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
% out = sinh(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = sinh(obj.data);

    
end
