function obj = log2(obj)
% Syntax:
%
% obj = log2(obj)
%
% Description:
%
% log2(obj) is the base 2 logarithm of the elements of obj.
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% Output:
% 
% - obj           : An object of class nb_math_ts where the data is the  
%                   base 2 logs of obj.
% 
% Examples:
% 
% obj = log2(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = log2(obj.data);

    
end
