function obj = setNext(obj,nextObj)
% Syntax:
% 
% obj = setNext(obj,nextObj)
% 
% Description:
% 
% Sets the next node (in a list)
% 
% Input:
% 
% - obj       : An object of class nb_Node
% 
% - nextObj   : The next object (class nb_Node) in an nb_List 
%               object
% 
% Output:
% 
% - obj       : An object of class nb_Node with the next property 
%               set
% 
% Examples:
% 
% obj = obj.setNext(aObj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.next = nextObj;

end
