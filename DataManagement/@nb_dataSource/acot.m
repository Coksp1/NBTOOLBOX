function obj = acot(obj)
% Syntax:
%
% obj = acot(obj)
%
% Description:
%
% Take acotangent of the data stored in the nb_cs object
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
% obj = acot(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = acot(obj.data);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@acot);
        
    end

end
