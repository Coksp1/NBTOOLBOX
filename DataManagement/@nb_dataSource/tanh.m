function obj = tanh(obj)
% Syntax:
%
% obj = tanh(obj)
%
% Description:
%
% tanh(obj) is the hyperbolic tangent of the elements of obj.
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
% out = tanh(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = tanh(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@tanh);
        
    end
    
end
