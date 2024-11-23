function obj = realsqrt(obj)
% Syntax:
%
% obj = realsqrt(obj)
%
% Description:
%
% realsqrt(obj) is the the square root of the elements of obj.
% An error is produced if obj contains negative elements.
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
% out = realsqrt(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = realsqrt(obj.data);

    
end
