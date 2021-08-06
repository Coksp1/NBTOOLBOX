function obj =   tan(obj)
% Syntax:
%
% obj = tan(obj)
%
% Description:
%
% Take the tangent of the data stored in the nb_ts object
% 
% Input:
% 
% - obj           : An object of class nb_ts
% 
% Output:
% 
% - obj           : An object of class nb_ts where the data hass been 
%                   transformed.
% 
% Examples:
% 
% obj = tan(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = tan(obj.data);
    
end
