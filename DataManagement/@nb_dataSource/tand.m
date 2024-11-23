function obj = tand(obj)
% Syntax:
%
% obj = tand(obj)
%
% Description:
%
% tand(obj) is the tangent of the elements of obj, expressed in degrees.
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
% out = tand(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = tand(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@tand);
        
    end
    
end
