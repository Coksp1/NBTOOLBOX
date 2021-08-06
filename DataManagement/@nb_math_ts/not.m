function a = not(a)
% Syntax:
%
% obj = not(obj)
%
% Description:
%
% The not operator (~)
% 
% Input:
% 
% - a         : An object of class nb_math_ts
%  
% Output:
% 
% - a         : An object of class nb_math_ts where each element of 
%               the input object are equal to 1 if it was 0, 
%               otherwise 0. The data will be a logical matrix
% 
% Examples:
%
% obj = ~obj;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    a.data = ~a.data;    

end
