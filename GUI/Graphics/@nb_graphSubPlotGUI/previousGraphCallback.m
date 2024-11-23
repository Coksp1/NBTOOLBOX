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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the current struct name
    displayedGraphMenu = findobj(gui.graphMenu,'checked','on');
    figNum             = get(displayedGraphMenu,'userdata') - 1;
    
    if figNum < 1
        return
    end
    
    % Locate the previous variables to display
    num     = gui.subPlotSize(1)*gui.subPlotSize(2);
    start   = (figNum - 1)*num + 1;
    finish  = figNum*num;
    varsT   = gui.vars;
    try  
        varsT = varsT(start:finish);  
    catch
        varsT = varsT(start:end);
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
    graphSubPlots(gui.plotter);
    
    % Check the dislpayed graph
    set(displayedGraphMenu,'checked','off');
    displayedGraphMenu = findobj(gui.graphMenu,'userdata',figNum);
    set(displayedGraphMenu,'checked','on');
    
end
