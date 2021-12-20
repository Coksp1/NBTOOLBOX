function obj = cotd(obj)
% Syntax:
%
% obj = cotd(obj)
%
% Description:
%
% cotd(obj) is the cotangent of the elements of obj, expressed in degrees.
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
% out = cotd(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = cotd(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cotd);
        
    end
    
end
