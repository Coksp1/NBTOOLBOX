function changeGraph(gui,hObject,~)
% Syntax:
%
% changeGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the plotted figure by changing the variablesToPlot
% property
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    page = get(hObject,'userdata');
    
    % Plot page in the GUI window
    gui.plotter.page = page;
    graph(gui.plotter);

    % Update the checked menu
    par   = get(get(hObject,'parent'),'parent');
    old   = findobj(par,'checked','on');
    set(old,'checked','off');
    set(hObject,'checked','on');

end
