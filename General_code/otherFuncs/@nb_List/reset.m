function obj = reset(obj,aObj,id)
% Syntax:
% 
% obj = reset(obj,aObj,id)
% 
% Description:
% 
% Reset an object of the nb_List object
% 
% Input:
% 
% - obj      : An object of class nb_List
% 
% - aObj     : All inputs are supported
% 
% - id       : A unique identifier as a string.
% 
% Output: 
% 
% - obj      : The nb_List object with the object with the 
%              given identifier reset.
% 
% Examples:
% 
% obj = reset(obj,nb_ts(),'data')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~ischar(id)
        error([mfilename ':: The id input must be a char (string).'])
    end

    foundID = obj.first.getID();
    found   = strcmpi(foundID,id);
    if found

        obj.first.setElement(aObj);

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

        temp.setElement(aObj);

    end

end

