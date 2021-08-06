function obj =   cot(obj)
% Syntax:
%
% obj = cot(obj)
%
% Description:
%
% Take cotangent of the data stored in the nb_ts, nb_cs or nb_data object
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
% obj = cot(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cot(obj.data);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cot);
        
    end

end
