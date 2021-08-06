function obj = sortTypes(obj,typesOrder)
% Syntax:
%
% obj = sortTypes(obj,typesOrder)
%
% Description:
%
% Sort the types alphabetically, or reorder them according to typesOrder.
% 
% Input:
% 
% - obj        : An object of class nb_cs
%
% - typesOrder : A cellstr with the wanted order of the types. If empty
%                an alphabetical order is used. 
%
%                Caution: Must contain all types of the object if not 
%                         empty.
% 
% Output:
% 
% - obj : An object of class nb_cs.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        typesOrder = {};
    end
    
    if isempty(typesOrder)
        [typesOrder,loc] = sort(obj.types);
    else
        
        if ~iscellstr(typesOrder)
            error([mfilename ':: The typesOrder input must be a cellstr.'])
        end
        
        if length(typesOrder) ~= obj.numberOfTypes
            error([mfilename ':: The typesOrder must have same length as the number of types of the object.'])
        end
        
        ind = ismember(obj.types,typesOrder);
        if any(~ind)
            error([mfilename ':: Did not find the types ' toString(obj.types(~ind)) ' in the typesOrder input.'])
        end
        [~,loc] = ismember(typesOrder,obj.types);
        
    end
    
    obj.data  = obj.data(loc,:,:);
    obj.types = typesOrder;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sortTypes,{typesOrder});
        
    end

end
