function prevObj = getPrev(obj)
% Syntax:
% 
% prevObj = getPrev(obj)
% 
% Description:
% 
% Get the previous node stored in an nb_List object
% 
% Input:
% 
% - obj       : An object of class nb_Node
% 
% Output:
% 
% - prevObj   : An object of class nb_Node or an empty double [].
% 
% Examples:
% 
% obj = obj.getPrev();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    prevObj = obj.prev;

end
