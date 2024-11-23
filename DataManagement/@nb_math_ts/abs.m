function obj = abs(obj)
% Syntax:
%
% obj = abs(obj)
%
% Description:
%
% Take the absolute value of each data elements of the nb_math_ts
% object
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
% out = abs(in);
% 
% Written by Kenneth S. Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = abs(obj.data);

end
