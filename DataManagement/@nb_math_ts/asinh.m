function obj = asinh(obj)
% Syntax:
%
% obj = asinh(obj)
%
% Description:
%
%  asinh(obj) is the inverse hyperbolic sine of the elements of obj
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
% out = asinh(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asinh(obj.data);

    
end
