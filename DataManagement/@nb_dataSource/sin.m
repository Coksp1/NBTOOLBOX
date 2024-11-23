function obj =   sin(obj)
% Syntax:
%
% obj = sin(obj)
%
% Description:
%
% Sine of argument in radians.
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Examples:
% 
% obj = sin(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = sin(obj.data);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sin);
        
    end

end
