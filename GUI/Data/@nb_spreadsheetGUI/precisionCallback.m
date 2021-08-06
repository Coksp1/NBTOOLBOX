function precisionCallback(gui,hObject,~)
% Syntax:
%
% precisionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    old = findobj(gui.viewMenu,'checked','on');
    set(old,'checked','off');
    
    gui.precision = get(hObject,'label');
    updateTable(gui);
    set(hObject,'checked','on');
     
end
