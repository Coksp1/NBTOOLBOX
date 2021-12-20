function obj = remove(obj,id)
% Syntax:
%
% obj = remove(obj,id)
%
% Description:
%
% Remove a data object from the given object. (Using the 
% objects identifier)
% 
% Input:
% 
% - obj : An object of class nb_DataCollection
% 
% - id  : The identifier of the object you want to remove. As a 
%         string.
% 
% Output:
% 
% - obj : An object of class nb_DataCollection with the data 
%         object with the given identifier removed.
% 
% Examples:
% 
% obj = obj.remove('Dataset1');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.list      = obj.list.remove(id);
    obj.objectsID = obj.list.ids;

end
