function obj = merge(obj,aObj)
% Syntax:
%
% obj = merge(obj,aObj)
%
% Description:
%
% Merge two objects of class nb_DataCollection
% 
% Collect each object stored in the two input objects of class 
% nb_DataCollection and store it in one nb_DataCollection object.
% 
% Input:
% 
% - obj  : An object of class nb_DataCollection
% 
% - aObj : An object of class nb_DataCollection
% 
% Output:
% 
% - obj  : An object of class nb_DataCollection, where all the data
%          objects of the two input objects of class 
%          nb_DataCollection are stored.
% 
% Examples:
% 
% obj = merge(obj,aObj)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_DataCollection') && isa(aObj,'nb_DataCollection') 
        error([mfilename ':: Not possible to merge an object of class ' class(obj) ' with an object of class ' class(aObj) '.'])
    end

    % Add each object stored in the nb_DataCollection object aObj
    % to the nb_DataCollection object obj.
    addedObjectNames = aObj.objectsID;
    for ii = 1:size(addedObjectNames,2)

        obj = obj.add(aObj.get(addedObjectNames{ii}),addedObjectNames{ii});

    end

end
