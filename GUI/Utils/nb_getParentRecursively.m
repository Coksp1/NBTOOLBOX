function parent = nb_getParentRecursively(gui)
% Syntax:
%
% parent = nb_getParentRecursively(gui)
%
% Description:
%
% Get oldest/highest parent of an object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isprop(gui, 'parent')
        parent = gui;
        return
    end
    try
        parent = gui.parent;
    catch
        try
            parent = gui.Parent;
        catch
            parent = gui;
            return
        end
    end
    while isprop(parent, 'parent')
        try
            parent = parent.parent;
        catch
            parent = parent.Parent;
        end
        if isa(parent,'matlab.ui.Figure')
            break;
        end
    end
    
end
