function obj = pow2(obj)
% Syntax:
%
% obj = pow2(obj)
%
% Description:
%
% pow2(obj) raises the number 2 to the power of the elements of obj
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% Output:
% 
% - obj           : An object of class nb_math_ts where the data are the   
%                   number 2 raised to the power of the elements of the  
%                   original object.
% 
% Examples:
% 
% obj = pow2(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = pow2(obj.data);

    
    
end
