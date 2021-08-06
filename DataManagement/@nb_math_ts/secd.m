function obj = secd(obj)
% Syntax:
%
% obj = secd(obj)
%
% Description:
%
% secd(obj) is the secant of the elements of obj, expressed in degrees.
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
% out = secd(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = secd(obj.data);

end
