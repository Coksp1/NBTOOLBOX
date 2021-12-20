function obj = cotd(obj)
% Syntax:
%
% obj = cotd(obj)
%
% Description:
%
% cotd(obj) is the cotangent of the elements of obj, expressed in degrees.
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
% out = cotd(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cotd(obj.data);

    
end
