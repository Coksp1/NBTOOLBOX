function ret = nb_isPanel(value)
% Syntax:
%
% ret = nb_isPanel(value)
%
% Description:
%
% Test if an object is of class panel.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
