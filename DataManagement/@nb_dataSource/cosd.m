function obj = cosd(obj)
% Syntax:
%
% obj = cosd(obj)
%
% Description:
%
% cosd(obj) is the cosine of the elements of obj, expressed in degrees.
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
% out = cosd(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = cosd(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cosd);
        
    end
    
end
