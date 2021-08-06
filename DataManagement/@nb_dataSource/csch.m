function obj = csch(obj)
% Syntax:
%
% obj = csch(obj)
%
% Description:
%
% csch(obj) is the hyperbolic cosecant of the elements of obj
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
% out = csch(in);
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = csch(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@csch);
        
    end
    
end
