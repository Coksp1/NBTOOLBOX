function obj = sind(obj)
% Syntax:
%
% obj = sind(obj)
%
% Description:
%
% sind(obj) is the sine of the elements of obj, expressed in degrees.
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
% out = sind(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = sind(obj.data);

    
end
