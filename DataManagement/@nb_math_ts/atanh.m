function obj = atanh(obj)
% Syntax:
%
% obj = atanh(obj)
%
% Description:
%
% atanh(obj) is the inverse hyperbolic tangent of the elements of obj.
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
% out = atanh(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = atanh(obj.data);

end
