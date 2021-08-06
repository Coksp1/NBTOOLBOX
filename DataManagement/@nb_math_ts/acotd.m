function obj = acotd(obj)
% Syntax:
%
% obj = acotd(obj)
%
% Description:
%
% acotd(obj) is the inverse cotangent, expressed in degrees,
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
% out = acotd(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acotd(obj.data);

    
end
