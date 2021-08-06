function obj = sqrt(obj)
% Syntax:
%
% obj = sqrt(obj)
%
% Description:
%
% sqrt(obj) is the square root of the elements of obj. Complex results
% are produced for non-positive elements.
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
% out = sqrt(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = sqrt(obj.data);

    
end
