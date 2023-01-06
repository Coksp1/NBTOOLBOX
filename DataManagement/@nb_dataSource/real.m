function obj = real(obj)
% Syntax:
%
% obj = real(obj)
%
% Description:
%
% real(obj) returns the real part of the elements in the nb_cs object
% 
% Input:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data
% 
% Examples:
% 
% obj = real(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = real(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@real);
        
    end
    
end
