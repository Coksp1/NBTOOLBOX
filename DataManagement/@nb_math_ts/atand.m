function obj = atand(obj)
% Syntax:
%
% obj = atand(obj)
%
% Description:
%
% atand(obj) is the inverse tangent, expressed in degrees,
% of the elements of obj.
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
% out = atand(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = atand(obj.data);
    
end
