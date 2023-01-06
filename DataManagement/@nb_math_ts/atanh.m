function obj = atanh(obj)
% Syntax:
%
% obj = atanh(obj)
%
% Description:
%
% Inverse hyperbolic tangent.
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
% out = atanh(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = atanh(obj.data);

end
