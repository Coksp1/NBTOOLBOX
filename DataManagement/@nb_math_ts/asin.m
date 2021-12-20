function obj =   asin(obj)
% Syntax:
%
% obj = sin(obj)
%
% Description:
%
% Take sin of the data stored in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_cs
% 
% Output:
% 
% - obj           : An object of class nb_cs where the data are on 
%                   sin.
% 
% Examples:
% 
% obj = sin(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asin(obj.data);
    
end
