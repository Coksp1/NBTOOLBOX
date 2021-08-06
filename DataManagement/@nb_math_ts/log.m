function obj = log(obj)
% Syntax:
%
% obj = log(obj)
%
% Description:
%
% Take log of the data stored in the nb_math_ts object
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% Output:
% 
% - obj           : An object of class nb_math_ts where the data  
%                   are on logs.
% 
% Examples:
% 
% obj = log(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = log(obj.data);

end
