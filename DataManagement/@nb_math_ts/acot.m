function obj =   acot(obj)
% Syntax:
%
% obj = cot(obj)
%
% Description:
%
% Take cotangent of the data stored in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_cs
% 
% Output:
% 
% - obj           : An object of class nb_cs where the data are on 
%                   cot.
% 
% Examples:
% 
% obj = cot(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acot(obj.data);
    
end
