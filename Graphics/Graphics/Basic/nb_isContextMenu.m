function ret = nb_isContextMenu(value)
% Syntax:
%
% ret = nb_isContextMenu(value)
%
% Description:
%
% Test if an object is of class ContextMenu.
% 
% Input:
% 
% - value : Any
% 
% Output:
% 
% - ret   : True if value is a handle to a figure.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = false;
    if isa(value,'matlab.ui.container.ContextMenu')
        ret = true;
    elseif nb_isScalarNumber(value) 
        if ishandle(value)
            type = get(value,'type');
            if strcmpi(type,'uicontextmenu')
                ret = true;
            end
        end
    end

end
