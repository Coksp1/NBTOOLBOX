function activateOptionsCallback(gui,hObject,~)
% Syntax:
%
% activateOptionsCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function called when selecting/deselecting Dates 
% vs Dates plot.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    switch lower(plotterT.plotType)

        case {'scatter','candle'}
            
            nb_errorWindow('It is not possible to do scatter or candle plot with Dates vs Dates plot.')
            set(hObject,'value',0);
            return
    end
        
    value = get(hObject,'value');
    if value % Selected Dates vs Dates plot
        
        % Add the default dates to plot
        %--------------------------------
        date                 = toString(plotterT.DB.startDate);
        plotterT.datesToPlot = {date};
       
        set(gui.panelHandle,'visible','on');
        
    else % Deselected Dates vs Dates plot
        
        % Remove the dates to plot
        %--------------------------------
        plotterT.datesToPlot = {};

        set(gui.panelHandle,'visible','off');
        
    end
    
    % Notify the graph GUI, so it can change some ui components
    %----------------------------------------------------------
    notify(gui,'changedGraphType');
    
end

