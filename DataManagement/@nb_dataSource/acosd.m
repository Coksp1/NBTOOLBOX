function obj = acosd(obj)
% Syntax:
%
% obj = acosd(obj)
%
% Description:
%
% acosd(obj) is the inverse cosine, expressed in degrees,
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
% out = acosd(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = acosd(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@acosd);
        
    end
    
end
