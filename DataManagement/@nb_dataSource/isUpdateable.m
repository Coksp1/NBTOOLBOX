function ret = isUpdateable(obj)
% Syntax:
%
% ret = isUpdateable(obj)
%
% Description:
%
% Test if this object is updateable.
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - ret       : 1 if updateable, otherwise 0.
%         
% Examples:
% 
% Written by Kenneth S. Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = obj.updateable;

end
