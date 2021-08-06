function obj = isnan(obj)
% Syntax:
%
% obj = isnan(obj)
%
% Description:
%
% Test if each element of an nb_math_ts object is nan. 
% 
% Input:
% 
% - obj  : An object of class nb_math_ts
% 
% Output:
% 
% - obj  : The object with data as logical. 1 if an element is 
%          nan, otherwise 0.
% 
% Examples:
% 
% obj = isnan(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = isnan(obj.data);

end
