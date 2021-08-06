function obj = remove(obj,id)
% Syntax:
% 
% obj = remove(obj,id)
% 
% Description:
% 
% Remove an object from the nb_List object
% 
% Input:
% 
% - obj      : An object of class nb_List
% 
% - id       : A unique identifier as a string.
% 
% Output: 
% 
% - obj      : The nb_List object without the object with the 
%              given identifier.
% 
% Examples:
% 
% obj = obj.remove('unique identifier')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(id)
        error([mfilename ':: The id input must be a char (string).'])
    end

    foundID = obj.first.getID();
    found   = strcmpi(foundID,id);
    if found

        temp      = obj.first;
        obj.first = temp.getNext();
        obj.first.setPrev([]);
        temp.setNext([]);
        obj.ids   = obj.ids(2:end); 

    else

        temp = obj.first;
        while ~found

            temp    = temp.getNext();
            foundID = temp.getID();
            found   = strcmpi(foundID,id);
            if found
                break;
            end

        end

        % Remove the object from the list
        p = temp.getPrev();
        n = temp.getNext();
        p.setNext(n);
        n.setPrev(p);
        temp.setPrev([]);
        temp.setNext([]);

        % Remove the id from the id cell
        removed = ~strcmpi(id,obj.ids);
        obj.ids = obj.ids(removed);

    end

end
