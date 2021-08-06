function nextObj = getNext(obj)
% Syntax:
% 
% nextObj = getNext(obj)
% 
% Description:
% 
% Get the next object stored in an nb_List object.
% 
% Input:
% 
% - obj       : An object of class nb_Node
% 
% Output:
% 
% - nextObj   : An object of class nb_Node or an empty double [].
% 
% Examples:
% 
% obj = obj.getNext();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nextObj = obj.next;

end
