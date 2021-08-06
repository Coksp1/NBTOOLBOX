function obj = sech(obj)
% Syntax:
%
% obj = sech(obj)
%
% Description:
%
% sech(obj) is the hyperbolic secant of the elements of obj.
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
% out = sech(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = sech(obj.data);

    
end
