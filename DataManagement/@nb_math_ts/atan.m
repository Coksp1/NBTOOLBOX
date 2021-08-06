function obj =   atan(obj)
% Syntax:
%
% obj = tan(obj)
%
% Description:
%
% Take the tangent of the data stored in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_cs
% 
% Output:
% 
% - obj           : An object of class nb_cs where the data hass been 
%                   transformed.
% 
% Examples:
% 
% obj = tan(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = atan(obj.data);
end
