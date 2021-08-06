function ret = isempty(obj)
% Syntax:
% 
% ret = isempty(obj)
% 
% Description:
% 
% A test if the object is empty, returns true if empty
% 
% Input:
% 
% - obj       : An object of class nb_Node
% 
% Output:
% 
% - ret       : true (1) of the object is empty, else false (0)
% 
% Examples:
% 
% ret = obj.isempty();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = isempty(obj.id);

end
