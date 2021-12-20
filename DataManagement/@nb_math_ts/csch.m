function obj = csch(obj)
% Syntax:
%
% obj = csch(obj)
%
% Description:
%
% csch(obj) is the hyperbolic cosecant of the elements of obj
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
% out = csch(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = csch(obj.data);

    
end
