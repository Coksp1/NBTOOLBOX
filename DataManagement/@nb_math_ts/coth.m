function obj = coth(obj)
% Syntax:
%
% obj = coth(obj)
%
% Description:
%
% coth(obj) is the hyperbolic cotangent of the elements of obj.
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
% out = coth(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = coth(obj.data);

    
end
