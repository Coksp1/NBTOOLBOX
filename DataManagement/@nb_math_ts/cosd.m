function obj = cosd(obj)
% Syntax:
%
% obj = cosd(obj)
%
% Description:
%
% cosd(obj) is the cosine of the elements of obj, expressed in degrees.
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
% out = cosd(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cosd(obj.data);

    
end
