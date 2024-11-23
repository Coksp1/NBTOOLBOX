function obj = acotd(obj)
% Syntax:
%
% obj = acotd(obj)
%
% Description:
%
% acotd(obj) is the inverse cotangent, expressed in degrees,
% of the elements of obj
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
% out = acotd(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = acotd(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@acotd);
        
    end
    
end
