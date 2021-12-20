function obj = asind(obj)
% Syntax:
%
% obj = asind(obj)
%
% Description:
%
%  asind(obj) is the inverse sine, expressed in degrees,
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
% out = asind(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asind(obj.data);

    
end
