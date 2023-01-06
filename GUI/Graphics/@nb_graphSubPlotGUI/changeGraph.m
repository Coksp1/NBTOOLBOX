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

    num     = gui.subPlotSize(1)*gui.subPlotSize(2);
    figNum  = get(hObject,'userdata');
    start   = (figNum - 1)*num + 1;
    finish  = figNum*num;
    try  
        varsT = gui.vars(start:finish);  
    catch
        varsT = gui.vars(start:end);
    end
   
    % Plot variables in the GUI window
    if ~isempty(gui.varsX)
        try  
            varsXT = gui.varsX(start:finish);  
        catch
            varsXT = gui.varsX(start:end);
        end 
        gui.plotter.set('variablesToPlot', varsT, 'variableToPlotX',varsXT);
    else
        gui.plotter.set('variablesToPlot', varsT);
    end
    gui.plotter.graphSubPlots();

    % Update the checked menu
    par = get(get(hObject,'parent'),'parent');
    old = findobj(par,'checked','on');
    set(old,'checked','off');
    set(hObject,'checked','on');

end
