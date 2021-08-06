function obj = atand(obj)
% Syntax:
%
% obj = atand(obj)
%
% Description:
%
% atand(obj) is the inverse tangent, expressed in degrees,
% of the elements of obj.
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
% out = atand(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = atand(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@atand);
        
    end
    
end
