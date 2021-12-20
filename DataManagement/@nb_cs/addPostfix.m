function obj = addPostfix(obj,postfix,names,type)
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
% - names   : A cellstr of the variables/types to add the prefix to. 
%             Default is all variable of the object.
% 
% - type    : Either: - 'variables' : To rename variables (default)
%                      - 'types'     : To rename types
%
% Output:
% 
% - obj     : An object of class nb_ts, nb_cs, nb_bd or nb_data with the 
%             postfix added to the variables selected.
% 
% Examples:
% 
% obj = obj.addPostfix('_NEW');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        type = 'variables';
        if nargin < 3
            names = {};
        end
    end
    
    switch(type)
        case {'variable', 'variables'}
            obj = addPostfix@nb_dataSource(obj, postfix, names);
        
        case {'type', 'types'}

            if isempty(names)
                names = obj.types;
            end

            [~, ind] = ismember(names, obj.types);
            names = strcat(names, postfix);
            obj.types(ind) = names;

            if obj.isUpdateable()
                % Add operation to the link property, so when the object 
                % is updated the operation will be done on the updated 
                % object
                obj = obj.addOperation(@addPostfix,{postfix,names,type});
            end
            
        otherwise
            error([mfilename ':: Type must be ''variables'' or ''types''']);
        
    end

end
