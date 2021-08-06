function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create the graph panel window 
    %--------------------------------------------------------------
    if isa(gui.parent,'nb_GUI')
        name = [gui.parent.guiName ': Graph Panel:'];
    else
        name = 'Graph Panel:';
    end

    currentMonitor    = nb_getCurrentMonitor();
    f    = nb_graphPanel('[4,3]',...
                         'advanced',       0,...
                         'visible',        'off',...
                         'units',          'characters',...
                         'position',       [40   15  186.4   43],...
                         'Color',          [1 1 1],...
                         'name',           name,...
                         'numberTitle',    'off',...
                         'dockControls',   'off',...
                         'menuBar',        'None',...
                         'toolBar',        'None',...
                         'CloseRequestFcn',@gui.close);
    main = f.figureHandle;                 
    nb_moveFigureToMonitor(main,currentMonitor,'center');
    gui.figureHandle = f;
    
    % Set up the menu
    %------------------------------------------------------
    plotterT = gui.plotter;
    gui.panelMenu = uimenu(main,'label','File');
        uimenu(gui.panelMenu,'Label','Save','Callback',@gui.save);
        uimenu(gui.panelMenu,'Label','Save as','Callback',@gui.saveAs);
        uimenu(gui.panelMenu,'Label','Export','separator','on','Callback',@gui.export);
        uimenu(gui.panelMenu,'Label','Copy to Clipboard','Callback',@gui.copyToClipboard,'accelerator','C');
        uimenu(gui.panelMenu,'Label','Redraw','Callback',@gui.updateGraph);
        uimenu(gui.panelMenu,'Label','Default Size','Callback',@gui.revertSize);
    
    gui.panelMenu = uimenu(main,'label','Panel');
        uimenu(gui.panelMenu,'Label','Add','Callback',@gui.addEmptyGraph);    
        
    gui.propertiesMenu = uimenu(main,'label','Properties');
        uimenu(gui.propertiesMenu,'Label','General','Callback',@plotterT.generalGUI);
        
    gui.advancedMenu = uimenu(main,'label','Advanced');
        uimenu(gui.advancedMenu,'Label','Figure Name','Callback',@gui.setFigureName);   
        
    % Add context menus to the graph objects of the 
    % nb_graph_subplot object
    %--------------------------------------------------------------
    graphOfPanel = gui.plotter.graphObjects;
    for ii = 1:length(graphOfPanel)
        
        subPlotterT = graphOfPanel{ii};
        addDefaultContextMenu(subPlotterT);
        if isa(subPlotterT,'nb_graph_adv')
            tempUICMenu = get(subPlotterT.plotter,'UIContextMenu');
        else
            tempUICMenu = get(subPlotterT,'UIContextMenu');
        end
        
        % Add copy and past menus
        uimenu(tempUICMenu,'Label','Copy','separator','on','callback',{@gui.copy,subPlotterT});
        uimenu(tempUICMenu,'Label','Paste','callback',{@gui.paste,subPlotterT});
        uimenu(tempUICMenu,'Label','Delete','callback',{@gui.deleteGraph,subPlotterT});
        
    end
    
    % Add listener to the graph objects of the nb_graph_subplot
    % object
    %--------------------------------------------------------------
    for ii = 1:length(graphOfPanel) 
        subPlotterT = graphOfPanel{ii};
        if isa(subPlotterT,'nb_graph_adv')
            plotter = subPlotterT.plotter;
            addlistener(subPlotterT,'updatedGraph',@gui.changedCallback);
            addlistener(subPlotterT,'titleOrFooterChange',@gui.updateGraph);
            addlistener(plotter,'updatedGraph',@gui.changedCallback);
            if isa(plotter,'nb_graph')
                addlistener(plotter,'updatedGraphStyle',@plotter.enableUIComponents);
                addlistener(plotter,'updatedGraphStyle',@gui.changedCallback);
            end
        else
            addlistener(subPlotterT,'updatedGraph',@gui.changedCallback);
            if isa(subPlotterT,'nb_graph')
                addlistener(subPlotterT,'updatedGraphStyle',@subPlotterT.enableUIComponents);
                addlistener(subPlotterT,'updatedGraphStyle',@gui.changedCallback);
            end
        end
    end
    
    % Add listener to the nb_graph_subplot object
    addlistener(gui.plotter,'updatedGraph',@gui.changedCallback);
    
    % Graph the subplot
    %------------------
    set(gui.plotter,'figureHandle',f);
    graph(gui.plotter);
    
    % Make window visible
    %--------------------
    set(main,'visible','on');
    
end
