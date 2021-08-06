function obj =   acos(obj)
% Syntax:
%
% obj = cos(obj)
%
% Description:
%
% Take cos of the data stored in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_cs
% 
% Output:
% 
% - obj           : An object of class nb_cs where the data are on 
%                   cos.
% 
% Examples:
% 
% obj = cos(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = acos(obj.data);
    
end
