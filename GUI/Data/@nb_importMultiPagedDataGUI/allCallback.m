function allCallback(gui,~,~)
% Syntax:
%
% allCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    value = nb_getUIControlValue(gui.allButton);
    if value
        enable = 'off';
    else
        enable = 'on';
    end
    set(gui.sheets,'enable',enable);

end
