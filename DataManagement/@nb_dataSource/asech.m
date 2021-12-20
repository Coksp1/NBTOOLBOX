function obj = asech(obj)
% Syntax:
%
% obj = asech(obj)
%
% Description:
%
% asech(obj) is the inverse hyperbolic secant of the elements of obj
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
% out = asech(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = asech(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@asech);
        
    end
    
end
