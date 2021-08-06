function changeGraph(gui,hObject,~)
% Syntax:
%
% changeGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the plotted figure by changing the index
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.page = get(hObject,'userdata');
    
    % Plot page in the GUI window
    updateGUI(gui)
    
end
