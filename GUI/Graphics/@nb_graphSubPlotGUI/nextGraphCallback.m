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
    figNum             = get(displayedGraphMenu,'userdata') + 1;
    
    % Locate the previous variables to display
    num    = gui.subPlotSize(1)*gui.subPlotSize(2);
    start  = (figNum - 1)*num + 1;
    finish = figNum*num;
    varsT  = gui.vars;
    try  
        varsT = varsT(start:finish);  
    catch
        varsT = varsT(start:end);
    end
    
    if isempty(varsT)
        return
    end
    
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
    
    % Plot variables in the GUI window
    gui.plotter.graphSubPlots();
    
    % Check the dislpayed graph
    set(displayedGraphMenu,'checked','off');
    displayedGraphMenu = findobj(gui.graphMenu,'userdata',figNum);
    set(displayedGraphMenu,'checked','on');
    
end
