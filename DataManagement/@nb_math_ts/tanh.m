function obj = tanh(obj)
% Syntax:
%
% obj = tanh(obj)
%
% Description:
%
% tanh(obj) is the hyperbolic tangent of the elements of obj.
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% Output: 
% 
% - obj       : An object of class nb_math_ts
% 
% Examples:
%
% out = tanh(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = tanh(obj.data);

    
end
