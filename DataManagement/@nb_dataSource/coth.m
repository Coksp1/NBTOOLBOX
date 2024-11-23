function obj = coth(obj)
% Syntax:
%
% obj = coth(obj)
%
% Description:
%
% coth(obj) is the hyperbolic cotangent of the elements of obj.
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
% out = coth(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = coth(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@coth);
        
    end
    
end
