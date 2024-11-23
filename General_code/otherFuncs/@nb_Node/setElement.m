function obj = setElement(obj,newElement)
% Syntax:
% 
% obj = setElement(obj,newElement)
% 
% Description:
% 
% Set the element of an object of class nb_Node
% 
% Input:
% 
% - obj        : An object of class nb_Node
% 
% - newElement : The new element. Can be of any MATLAB type 
%                (object)
% 
% Output:
% 
% - obj        : An object of class nb_Node with the new element
%                stored
% 
% Examples:
% 
% obj = obj.setElement(newElement);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.element = newElement;

end
