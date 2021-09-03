function obj = acsch(obj)
% Syntax:
%
% obj = acsch(obj)
%
% Description:
%
% acsch(obj) is the inverse hyperbolic cosecant of the elements of obj
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
% out = acsch(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj.data = acsch(obj.data);

    
end