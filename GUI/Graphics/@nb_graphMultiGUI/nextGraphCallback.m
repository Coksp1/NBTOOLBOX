function nextGraphCallback(gui,~,~)
% Syntax:
%
% nextGraphCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Display previous graph callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the current struct name
    displayedGraphMenu = findobj(gui.graphMenu,'checked','on');
    gui.page           = get(displayedGraphMenu,'userdata') + 1;
    if gui.page > numel(gui.plotter)
        gui.page = numel(gui.plotter);
        return
    end
    
    % Plot page in the GUI window
    updateGUI(gui);
    
end
