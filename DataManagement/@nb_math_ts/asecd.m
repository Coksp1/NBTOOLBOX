function obj = asecd(obj)
% Syntax:
%
% obj = asecd(obj)
%
% Description:
%
% asecd(obj) is the inverse secant, expressed in degrees,
% of the elements of obj
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
% out = asecd(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asecd(obj.data);

    
end
