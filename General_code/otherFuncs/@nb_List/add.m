function obj = add(obj,aObj,id)
% Syntax:
% 
% obj = add(obj,aObj,id)
% 
% Description:
% 
% Add object to the nb_list object
% 
% Input:
% 
% - obj      : An object of class nb_List
% 
% - aObj     : All inputs are supported
% 
% - id       : The identifier of the given input. As a string.
%
%              Caution : If not given it will be stored with a 
%                        string with the number of existing objects
%                        stored in the object + 1. I.e. if it
%                        is stored 2 object in the list, the 
%                        identifier for the added object will be 
%                        '3'.
% 
% Output: 
% 
% - obj      : An object of class nb_List, where the input aObj are
%              added to the list of stored objects.
% 
% Examples:
% 
% obj.add(aObj);
% obj.add(aObj, 'unique identifier');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        id = int2str(size(obj.ids,2));
    else
        if ~ischar(id)
            error([mfilename ':: The id input must be a char (string).'])
        end
    end

    if find(strcmpi(id,obj.ids))
        error([mfilename ':: Cannot add a object to a list with the same identifier as another object already in the list.'])
    end

    % Add object to the list
    if isempty(obj.first)
        obj.first = nb_Node(aObj,id);
        obj.last  = obj.first;
    else
        tempObj  = obj.last;
        tempObj.setNext(nb_Node(aObj,id));
        obj.last = tempObj.getNext();
        obj.last.setPrev(tempObj);
    end

    % Add id to the 'ids' property
    obj.ids = [obj.ids, {id}];

end
