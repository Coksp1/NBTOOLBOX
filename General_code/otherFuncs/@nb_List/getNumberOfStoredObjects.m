function number = getNumberOfStoredObjects(obj)
% Syntax:
% 
% number = getNumberOfStoredObjects(obj)
% 
% Description:
% 
% Get the number of objects stored in the list
% 
% Input:
% 
% - obj       : An object of class nb_List
% 
% Output:
% 
% - number    : The number of stored objects as an integer 
%               (double).
% 
% Examples:
% 
% n = obj.getNumberOfStoredObjects()
% 
% Written by Kenneth S. Paulsen    

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    number = size(obj.ids,2);

end
