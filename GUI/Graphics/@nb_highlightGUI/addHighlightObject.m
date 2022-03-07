function addHighlightObject(gui,~,~)
% Syntax:
%
% addHighlightObject(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    objects  = get(gui.popupmenu1,'string');

    if strcmpi(objects{1},' ')
        highlightName = 'Highlight 1';  
        num           = 0;
        objects       = {};
    else

        num   = size(objects,1);
        found = 1;
        kk    = 1;
        while found
            highlightName = ['Highlight ' int2str(kk)];
            found         = ~isempty(find(strcmp(highlightName,objects),1));
            kk            = kk + 1;
        end

    end

    % Create new Highlight object
    %----------------------------
        
    % Location
    old = plotterT.highlight;
    if strcmpi(plotterT.plotType,'scatter')
        new = {0,1};
    elseif isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_graph_data')
        new  = {plotterT.startGraph,plotterT.startGraph + 1};
    else
        new = {plotterT.typesToPlot{1},plotterT.typesToPlot{2}};
    end
    plotterT.highlight = [old, {new}];

    % Color
    old = plotterT.highlightColor;
    new = {[0 0 0]};
    plotterT.highlightColor = [old, new];
           
    % Notify listeners
    notify(gui,'changedGraph');
    
    % Update the line object selection list 
    set(gui.popupmenu1,'string',[objects;highlightName],'value',num + 1);
    
    % Switch the line object of interest
    updatePanel(gui,highlightName,0);
    
end
