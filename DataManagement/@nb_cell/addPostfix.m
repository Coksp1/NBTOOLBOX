function obj = addPostfix(obj,postfix,names,type)
% Syntax:
%
% obj = addPostfix(obj,postfix)
% 
% Description:
%
% Add a postfix to all elements of the data of the nb_cell object.
% 
% Input:
% 
% - obj     : An object of class nb_cell
% 
% - postfix : The prefix to add to all string elements of the objects cell
%             data.
%
% Output:
% 
% - obj     : An object of class nb_cell with the postfix added.
% 
% Examples:
% 
% obj = obj.addPostfix('_NEW');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        type = 'variables';
        if nargin < 3
            names = {};
        end
    end
    
    cData      = obj.c(:);
    ind        = cellfun(@(x)isa(x,'char'),cData);
    cData(ind) = strcat(cData(ind),postfix);
    obj.c      = cData;
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addPostfix,{postfix,names,type});
    end

end
