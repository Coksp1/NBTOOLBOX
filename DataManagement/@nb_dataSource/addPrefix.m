function obj = addPrefix(obj,prefix,vars)
% Syntax:
%
% obj = addPrefix(obj,prefix)
% obj = addPrefix(obj,prefix,vars)
%
% Description:
%
% Add a prefix to all the variables in the nb_ts, nb_cs or nb_data object,  
% or a provided variable group.
% 
% Input:
% 
% - obj    : An object of class nb_ts, nb_cs or nb_data
% 
% - prefix : The prefix to add to all the variables of the object. 
%            Must be a string
%
% - vars   : A cellstr of the variable to add the prefix to. 
%            Default is all variable of the object.
%            
% Output:
% 
% - obj    : An object of class nb_ts, nb_cs or nb_data with a prefix  
%            added to the selected variables
% 
% Example:
% 
% obj = obj.addPrefix('NEMO.');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        vars = {};
    end

    if isempty(vars)

        var = obj.variables;
        var = strcat(prefix,var);
        obj.variables = var;
        
    else
        
        [~,ind] = ismember(vars,obj.variables);
        var     = strcat(prefix,vars);
        obj.variables(ind) = var;
        
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addPrefix,{prefix,vars});
        
    end

end
