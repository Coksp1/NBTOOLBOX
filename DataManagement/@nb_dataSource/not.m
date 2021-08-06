function a = not(a)
% Syntax:
%
% a = not(a)
%
% Description:
%
% The not operator (~).
%
% Input:
% 
% - a : An object of class nb_dataSource.
% 
% Output:
% 
% - a : An object of class nb_dataSource. Where the not operator 
%       has evaluated all the data elements of the object.
%       The data will be a logical matrix. 
%
% Examples:
%
% a = ~a;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    a.data = ~a.data;
    if a.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        a = a.addOperation(@not);
    end
    
end
