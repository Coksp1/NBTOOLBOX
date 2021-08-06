function obj = acosh(obj)
% Syntax:
%
% obj = acosh(obj)
%
% Description:
%
% acosh(obj) is the inverse hyperbolic cosine of the elements of obj
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
% out = acosh(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acosh(obj.data);

    
end
