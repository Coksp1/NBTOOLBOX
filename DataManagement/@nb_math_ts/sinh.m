function obj = sinh(obj)
% Syntax:
%
% obj = sinh(obj)
%
% Description:
%
% sinh(obj) is the hyperbolic sine of the elements of obj.
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
% out = sinh(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = sinh(obj.data);

    
end
