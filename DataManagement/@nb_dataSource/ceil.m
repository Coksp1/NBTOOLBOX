function obj = ceil(obj)
% Syntax:
%
% obj = ceil(obj)
%
% Description:
%
% ceil(obj) rounds the elements of obj to the nearest integers
% towards infinity.
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
% out = ceil(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = ceil(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@ceil);
        
    end
    
end
