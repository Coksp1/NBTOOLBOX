function obj = addPrefix(obj,prefix,names,type)
% Syntax:
%
% obj = addPrefix(obj,prefix)
% 
% Description:
%
% Add a prefix to all elements of the data of the nb_cell object.
% 
% Input:
% 
% - obj    : An object of class nb_cell
% 
% - prefix : The prefix to add to all string elements of the objects cell
%            data.
%
% Output:
% 
% - obj     : An object of class nb_cell with the prefix added.
% 
% Examples:
% 
% obj = obj.addPrefix('_NEW');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        type = 'variables';
        if nargin < 3
            names = {};
        end
    end
    
    cData      = obj.c(:);
    ind        = cellfun(@(x)isa(x,'char'),cData);
    cData(ind) = strcat(prefix,cData(ind));
    obj.c      = cData;
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addPrefix,{prefix,names,type});
    end

end
