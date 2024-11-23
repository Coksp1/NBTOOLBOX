function nb_closeGUIWindow(hObject,~)
% Syntax:
%
% nb_closeGUIWindow(hObject,event)
%
% Description:
%
% Close GUI window callback function.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    hierarchy                = get(hObject,'userdata');
    figParent                = hierarchy.parent;
    parentHierarchy          = get(figParent,'userdata');
    ind                      = hObject == parentHierarchy.children;
    parentHierarchy.children = parentHierarchy.children(~ind);

end
