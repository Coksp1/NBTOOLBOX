function storedObj = get(obj,id)
% Syntax:
% 
% storedObj = get(obj,id)
% 
% Description:
% 
% Get a stored object from a list.
% 
% Input:
% 
% - obj       : An object of class nb_List
% 
% - id        : The identifier of the stored object. As a string.
% 
% Output:
% 
% - storedObj : The stored object. Could be of any type.
% 
% Examples:
% 
% obj.get('unique identifier');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen


    if ~ischar(id)
        error([mfilename ':: The id input must be a char (string).'])
    end

    found     = 0;
    storedObj = obj.first;
    while ~found

        foundID = storedObj.getID();
        found   = strcmpi(foundID,id);
        if found
            break;
        end

        if storedObj.hasNext()
            storedObj = storedObj.getNext();
        else
            error([mfilename ':: Did not find a object with the given identifier: ' id])
        end

    end

    storedObj = storedObj.getElement();

end
