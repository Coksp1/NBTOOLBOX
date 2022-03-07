function elem = getElement(obj)
% Syntax:
% 
% elem = getElement(obj)
% 
% Description:
% 
% Get the elements of an nb_Node object
% 
% Input:
% 
% - obj       : An object of class nb_Node
% 
% Output:
% 
% - obj       : The element of the nb_Node object. Can be of any
%               MATLAB types (objects).
% 
% Examples:
% 
% elem = obj.getElement();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    elem = obj.element;

end
