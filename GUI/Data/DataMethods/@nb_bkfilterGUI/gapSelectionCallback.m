function gapSelectionCallback(gui,~,~)
% Syntax:
%
% gapSelectionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    value = get(gui.rb1,'value');
    if value
        set(gui.edit2,'enable','on');
    else
        set(gui.edit2,'enable','off');
    end

end
