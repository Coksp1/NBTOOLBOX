function obj = log10(obj)
% Syntax:
%
% obj = log10(obj)
%
% Description:
%
% Take the common (base 10) log of the data stored in the nb_ts, nb_cs or 
% nb_data object
% 
% Input:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data where the  
%                   data are on (base 10) logs.
% 
% Examples:
% 
% obj = log10(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = log10(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@log10);
        
    end
    
end
