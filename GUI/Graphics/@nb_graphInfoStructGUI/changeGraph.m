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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    figName        = get(hObject,'Label');
    tempInfoStruct = struct();
    tempInfoStruct.(figName) = gui.GraphStruct.(figName);

    % Plot variables in the GUI window
    try
        gui.plotter.set('graphStruct', tempInfoStruct);
        gui.plotter.graphInfoStruct();
    catch
        return
    end

    % Update the checked menu
    par = get(get(hObject,'parent'),'parent');
    old = findobj(par,'checked','on');
    set(old,'checked','off');
    set(hObject,'checked','on');

end
