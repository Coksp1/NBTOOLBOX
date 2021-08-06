function obj = acosd(obj)
% Syntax:
%
% obj = acosd(obj)
%
% Description:
%
% acosd(obj) is the inverse cosine, expressed in degrees,
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
% out = acosd(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acosd(obj.data);
    
end
