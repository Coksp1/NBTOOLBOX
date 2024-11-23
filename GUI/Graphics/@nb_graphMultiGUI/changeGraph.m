function changeGraph(gui,hObject,~)
% Syntax:
%
% changeGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the plotted figure by changing the index
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    gui.page = get(hObject,'userdata');
    
    % Plot page in the GUI window
    updateGUI(gui)
    
end
