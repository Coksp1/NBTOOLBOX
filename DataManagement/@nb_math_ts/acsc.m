function obj =   acsc(obj)
% Syntax:
%
% obj = csc(obj)
%
% Description:
%
% Take csc of the data stored in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_cs
% 
% Output:
% 
% - obj           : An object of class nb_cs where the data has been transformed
% 
% Examples:
% 
% obj = csc(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acsc(obj.data);
    
end
