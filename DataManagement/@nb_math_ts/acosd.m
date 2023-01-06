function obj = acosd(obj)
% Syntax:
%
% obj = acosd(obj)
%
% Description:
%
% Inverse cosine, expressed in degrees
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% Output: 
% 
% - obj : An object of class nb_math_ts
% 
% Examples:
%
% out = acosd(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = acosd(obj.data);
    
end
