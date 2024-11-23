function obj = exp(obj)
% Syntax:
%
% obj = exp(obj)
%
% Description:
%
% Take exp of the data stored in the nb_ts, nb_cs or nb_data object
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
% obj = exp(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = exp(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@exp);
        
    end
    
end
