function obj = asech(obj)
% Syntax:
%
% obj = asech(obj)
%
% Description:
%
% asech(obj) is the inverse hyperbolic secant of the elements of obj
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
% out = asech(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asech(obj.data);

    
end
