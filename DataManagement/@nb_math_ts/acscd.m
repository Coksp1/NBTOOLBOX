function obj = acscd(obj)
% Syntax:
%
% obj = acscd(obj)
%
% Description:
%
% acscd(obj) is the inverse cosecant, expressed in degrees,
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
% out = acscd(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acscd(obj.data);

    
end
