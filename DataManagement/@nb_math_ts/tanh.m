function obj = tanh(obj)
% Syntax:
%
% obj = tanh(obj)
%
% Description:
%
% Hyperbolic tangent.
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
% out = tanh(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = tanh(obj.data);
  
end
