function obj = exp(obj)
% Syntax:
%
% obj = exp(obj)
%
% Description:
%
% Take exp of the data stored in the nb_math_ts object
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% Output:
% 
% - obj           : An object of class nb_math_ts where the data  
%                   are equal to e raised to the data.
% 
% Examples:
% 
% obj = exp(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = exp(obj.data);

end
