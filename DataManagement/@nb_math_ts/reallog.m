function obj = reallog(obj)
% Syntax:
%
% obj = reallog(obj)
%
% Description:
%
% Take the natural logarithm of the data stored in the object
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% Output:
% 
% - obj           : An object of class nb_math_ts where the data are the  
%                   natural logarithms of the elements of the original 
%                   object. 
%
% Examples:
% 
% obj = reallog(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = reallog(obj.data);
 

end
