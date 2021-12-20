function obj = cosh(obj)
% Syntax:
%
% obj = acsch(obj)
%
% Description:
%
% cosh(obj) is the hyperbolic cosine of the elements of obj.
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
% out = acsch(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cosh(obj.data);

    
end
