function obj = acoth(obj)
% Syntax:
%
% obj = acoth(obj)
%
% Description:
%
% acoth(obj) is the inverse hyperbolic cotangent of the elements of obj
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
% out = acoth(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acoth(obj.data);
    
    
end
