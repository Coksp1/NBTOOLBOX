function obj = abs(obj)
% Syntax:
%
% obj = abs(obj)
%
% Description:
%
% Take the absolute value of each data elements of the object
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Output: 
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Examples:
%
% out = abs(in);
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = abs(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@abs);
        
    end
    
end
