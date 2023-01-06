function previousPage(gui,~,~)
% Syntax:
%
% previousPage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if gui.page ~= 1
        gui.page = gui.page - 1;
        updateTable(gui);
    end
    
end
