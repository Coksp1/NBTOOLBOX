function addLineObject(gui,~,~)
% Syntax:
%
% addLineObject(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for adding a line object 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT    = gui.plotter;
    lineObjects = get(gui.popupmenu1,'string');

    if strcmpi(lineObjects{1},' ')
        lineName    = 'Line 1';  
        num         = 0;
        lineObjects = {};
    else

        num   = size(lineObjects,1);
        found = 1;
        kk    = 1;
        while found
            lineName = ['Line ' int2str(kk)];
            found     = ~isempty(find(strcmp(lineName,lineObjects),1));
            kk        = kk + 1;
        end

    end

    % Create new line object
    %-----------------------
    if strcmpi(gui.type,'horizontal')
    
        % Location
        old = plotterT.horizontalLine;
        new = 0;
        plotterT.horizontalLine = [old, new];
        
        % Color
        old = plotterT.horizontalLineColor;
        new = {[0 0 0]};
        plotterT.horizontalLineColor = [old, new];
        
        % Line Style
        old = plotterT.horizontalLineStyle;
        new = {'-'};
        plotterT.horizontalLineStyle = [old, new];
        
    elseif strcmpi(gui.type,'vertical')
        
        % Location
        old = plotterT.verticalLine;
        if strcmpi(plotterT.plotType,'scatter')
            new = {0};
        elseif isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_graph_data')
            new  = {plotterT.startGraph + 1};
        else
            new = plotterT.typesToPlot{1};
        end
        plotterT.verticalLine = [old, new];
        
        % Color
        old = plotterT.verticalLineColor;
        new = {[0 0 0]};
        plotterT.verticalLineColor = [old, new];
        
        % Line Style
        old = plotterT.verticalLineStyle;
        new = {'--'};
        plotterT.verticalLineStyle = [old, new];
        
        % Limits
        old = plotterT.verticalLineLimit;
        new = {[]};
        plotterT.verticalLineLimit = [old, new];
        
    else
        
        old = plotterT.annotation;
        new = {nb_drawLine()};
        plotterT.set('annotation',[old, new]);
        
    end
    
    % Notify listeners
    notify(gui,'changedGraph');
    
    % Update the line object selection list 
    set(gui.popupmenu1,'string',[lineObjects;lineName],'value',num + 1);
    
    % Switch the line object of interest
    updateLinePanel(gui,lineName,0);
    
end
