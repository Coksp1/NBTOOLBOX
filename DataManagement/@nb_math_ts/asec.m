function obj =  asec(obj)
% Syntax:
%
% obj = sec(obj)
%
% Description:
%
% Take sec of the data stored in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_cs
% 
% Output:
% 
% - obj           : An object of class nb_cs where the data are on 
%                   sec.
% 
% Examples:
% 
% obj = sec(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asec(obj.data);
end
