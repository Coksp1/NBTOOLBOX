function obj = setPrev(obj,prevObj)
% Syntax:
% 
% obj = setPrev(obj,nextObj)
% 
% Description:
% 
% Sets the previous node (in a list)
% 
% Input:
% 
% - obj       : An object of class nb_Node
% 
% - nextObj   : The previous object (class nb_Node) in an nb_List 
%               object
% 
% Output:
% 
% - obj       : An object of class nb_Node with the prev property 
%               set
% 
% Examples:
% 
% obj = obj.setPrev(aObj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.prev = prevObj;

end
