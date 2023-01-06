function obj = uminus(obj)
% Syntax:
%
% obj = uminus(obj)
%
% Description
%
% Unary minus 
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% Output:
% 
% - obj       : An nb_math_ts object where all the data are the 
%               unary minus of the input objects data
% 
% Examples:
% 
% obj = -obj;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = -obj.data;

end
