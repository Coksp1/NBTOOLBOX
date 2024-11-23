function obj = realsqrt(obj)
% Syntax:
%
% obj = realsqrt(obj)
%
% Description:
%
% realsqrt(obj) is the the square root of the elements of obj.
% An error is produced if obj contains negative elements.
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
% out = realsqrt(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.data = realsqrt(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@realsqrt);
        
    end
    
end
