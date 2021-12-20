function obj = addPostfix(obj,postfix,vars)
% Syntax:
%
% obj = addPostfix(obj,postfix)
% obj = addPostfix(obj,postfix,vars)
% 
% Description:
%
% Add a postfix to all the variables in the nb_ts, nb_cs or nb_data object, 
% or a a provided variable group.
% 
% Input:
% 
% - obj     : An object of class nb_ts, nb_cs or nb_data
% 
% - postfix : The postfix to add to all the variables of the 
%             object. Must be a string
%
% - vars    : A cellstr of the variable to add the prefix to. 
%             Default is all variable of the object.
% 
% Output:
% 
% - obj     : An object of class nb_ts, nb_cs or nb_data with the postfix  
%             added to the variables selected
% 
% Examples:
% 
% obj = obj.addPostfix('_NEW');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        vars = {};
    end

    if isempty(vars)
        var           = obj.variables;
        var           = strcat(var,postfix);
        obj.variables = var;
    else
        [~,ind]            = ismember(vars,obj.variables);
        var                = strcat(vars,postfix);
        obj.variables(ind) = var;
    end
    
    % Re-sort
    if obj.sorted
        [obj.variables,indS] = sort(obj.variables);
        obj.data             = obj.data(:,indS,:);
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addPostfix,{postfix,vars});
        
    end

end
