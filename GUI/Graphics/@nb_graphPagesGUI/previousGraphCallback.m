function previousGraphCallback(gui,~,~)
% Syntax:
%
% previousGraphCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Display previous graph callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the current struct name
    displayedGraphMenu = findobj(gui.graphMenu,'checked','on');
    page               = get(displayedGraphMenu,'userdata') - 1;
    
    if page < 1
        return
    end
    
    % Plot page in the GUI window
    gui.plotter.page = page;
    graph(gui.plotter);
    
    % Check the dislpayed graph
    set(displayedGraphMenu,'checked','off');
    displayedGraphMenu = findobj(gui.graphMenu,'userdata',page);
    set(displayedGraphMenu,'checked','on');
    
end
