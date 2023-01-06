function obj =   cos(obj)
% Syntax:
%
% obj = cos(obj)
%
% Description:
%
% Cosine
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% Output:
% 
% - obj : An object of class nb_math_ts.
% 
% Examples:
% 
% obj = cos(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = cos(obj.data);
    
end
