function previousPage(gui,~,~)
% Syntax:
%
% previousPage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if gui.page ~= 1
        gui.page = gui.page - 1;
        updateTable(gui);
    end
    
end
