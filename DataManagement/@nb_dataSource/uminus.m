function obj = uminus(obj)
% Syntax:
%
% obj = uminus(obj)
%
% Description:
%
% Unary minus 
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj       : A nb_ts, nb_cs or nb_data object where all the data are  
%               the unary minus of the input objects data
% 
% Examples:
% 
% obj = -obj;
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = -obj.data;
    
    if obj.isUpdateable() 
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@uminus);
        
    end

end
