function gapSelectionCallback(gui,~,~)
% Syntax:
%
% gapSelectionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    value = get(gui.rb1,'value');
    if value
        set(gui.edit2,'enable','on');
    else
        set(gui.edit2,'enable','off');
    end

end
