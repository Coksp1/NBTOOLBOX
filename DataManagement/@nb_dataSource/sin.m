function obj =   sin(obj)
% Syntax:
%
% obj = sin(obj)
%
% Description:
%
% Take sine of the data stored in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data
% 
% Examples:
% 
% obj = sin(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = sin(obj.data);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sin);
        
    end

end
