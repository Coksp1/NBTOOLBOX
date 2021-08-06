function trendSelectionCallback(gui,~,~)
% Syntax:
%
% trendSelectionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    value = get(gui.rb2,'value');
    if value
        set(gui.edit3,'enable','on');
    else
        set(gui.edit3,'enable','off');
    end

end
