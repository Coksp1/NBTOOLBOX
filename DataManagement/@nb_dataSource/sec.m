function obj =  sec(obj)
% Syntax:
%
% obj = sec(obj)
%
% Description:
%
% Secant of argument in radians.
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
% obj = sec(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = sec(obj.data);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sec);
        
    end

end
