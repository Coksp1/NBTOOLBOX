function previousGraphCallback(gui,~,~)
% Syntax:
%
% previousGraphCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Display previous graph callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get the current struct name
    displayedGraphMenu = findobj(gui.graphMenu,'checked','on');
    gui.page           = get(displayedGraphMenu,'userdata') - 1;
    
    if gui.page < 1
        gui.page = 1;
        return
    end
    
    % Plot page in the GUI window
    updateGUI(gui);
     
end
