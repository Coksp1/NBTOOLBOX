function ret = hasNext(obj)
% Syntax:
% 
% obj = setNext(obj,nextObj)
% 
% Description:
% 
% Test for the existence of a next object (when stored in an 
% nb_List object)
% 
% Input:
% 
% - obj       : An object of class nb_Node
% 
% Output:
% 
% - ret       : true (1) if the next object is not empty, otherwise
%               false (0).
% 
% Examples:
% 
% ret = obj.hasNext();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = ~isempty(obj.next);

end
