function obj = tand(obj)
% Syntax:
%
% obj = tand(obj)
%
% Description:
%
% tand(obj) is the tangent of the elements of obj, expressed in degrees.
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
% out = tand(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = tand(obj.data);

end
