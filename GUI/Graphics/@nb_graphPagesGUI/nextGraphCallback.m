function nextGraphCallback(gui,~,~)
% Syntax:
%
% nextGraphCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Display next graph callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the current struct name
    displayedGraphMenu = findobj(gui.graphMenu,'checked','on');
    page               = get(displayedGraphMenu,'userdata') + 1;
    if isa(gui.plotter,'nb_table_cell')
        if page > size(gui.plotter.DB,3)
            return
        end
    else
        if page > gui.plotter.DB.numberOfDatasets
            return
        end
    end
    
    % Plot page in the GUI window
    gui.plotter.page = page;
    graph(gui.plotter);
    
    % Check the dislpayed graph
    set(displayedGraphMenu,'checked','off');
    displayedGraphMenu = findobj(gui.graphMenu,'userdata',page);
    set(displayedGraphMenu,'checked','on');
    
end
