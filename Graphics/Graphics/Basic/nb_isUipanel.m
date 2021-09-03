function ret = nb_isUipanel(value)
% Syntax:
%
% ret = nb_isUipanel(value)
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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    ret = false;
    if isa(value,'matlab.ui.container.Panel')
        ret = true;
    elseif nb_isScalarNumber(value) 
        if ishandle(value)
            type = get(value,'type');
            if strcmpi(type,'uipanel')
                ret = true;
            end
        end
    end

end