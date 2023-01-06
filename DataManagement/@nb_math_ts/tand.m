function obj = tand(obj)
% Syntax:
%
% obj = tand(obj)
%
% Description:
%
% Tangent, expressed in degrees.
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
% out = tand(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = tand(obj.data);

end
