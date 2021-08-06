function obj = asinh(obj)
% Syntax:
%
% obj = asinh(obj)
%
% Description:
%
% asinh(obj) is the inverse hyperbolic sine of the elements of obj
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
% out = asinh(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asinh(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@asinh);
        
    end
    
end
