function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG. Make GUI figure
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the variables 
    if isempty(gui.plotter.variablesToPlot)
        varsT = gui.plotter.DB.variables;
    else
        varsT = gui.plotter.variablesToPlot;
    end
    gui.vars = varsT;
    
    if isempty(varsT)
        nb_errorWindow('No variables to plot.')
        return
    end
    
    if isa(gui.plotter,'nb_graph_data')
        if isempty(gui.plotter.variableToPlotX)
            varsXT = {};
        else
            varsXT = gui.plotter.variableToPlotX;
        end
        gui.varsX = varsXT;
    end
    
    
    if isempty(gui.parent)
        name = 'Graphics';
        set(0,'DefaultFigureWindowStyle','normal');
    else
        parent = nb_getParentRecursively(gui);
        name   = [parent.guiName ': Graphics'];
    end
    if ~isempty(gui.figureName)
        name = [name, ': ' gui.figureName];
    end
    
    if isempty(gui.position)
        gui.position = [40,15,186.4,43];
    end
    
    % Create the main window
    %------------------------------------------------------
    currentMonitor = nb_getCurrentMonitor();
    f    = nb_graphPanel('[4,3]',...
                         'visible',        'off',...
                         'units',          'characters',...
                         'position',       gui.position,...
                         'Color',          [1 1 1],...
                         'name',           name,...
                         'numberTitle',    'off',...
                         'dockControls',   'off',...
                         'menuBar',        'None',...
                         'toolBar',        'None',...
                         'tag',            'main');
    main = f.figureHandle;                 
    nb_moveFigureToMonitor(main,currentMonitor,'center');      

    % Get number of variables plotted per figure
    %------------------------------------------------------
    num         = gui.subPlotSize(1)*gui.subPlotSize(2);
    numOfGraphs = ceil(length(varsT)/num);

    % Get the plotter object
    %------------------------------------------------------
    plotterT = gui.plotter;
    
    % Set up the menu
    %------------------------------------------------------
    gui.graphMenu = uimenu(main,'label','Graph','enable','off');
        nMenus = ceil(numOfGraphs/30);
        graphs = uimenu(gui.graphMenu,'Label','Graphs');
        if nMenus > 1
            menus = struct();
            label = 'Graphs';
            for ii = 2:nMenus
                label = [label,'.']; %#ok<AGROW>
                menus.(['graphs' int2str(ii)]) = uimenu(gui.graphMenu,'Label',label);
            end
        end
        
        % Add next prev buttons
        uimenu(gui.graphMenu,...
            'separator',    'on',...
            'label',        'Previous',...
            'callback',     @gui.previousGraphCallback,...
            'accelerator',  'Q',...
            'interruptible','off');
        uimenu(gui.graphMenu,...
            'label',        'Next',...
            'callback',     @gui.nextGraphCallback,...
            'accelerator',  'A',...
            'interruptible','off');
        
        uimenu(gui.graphMenu,'Label','Export','separator','on','Callback',@gui.export);
        uimenu(gui.graphMenu,'Label','Print','Callback',@gui.printFigure);
        uimenu(gui.graphMenu,'Label','Spreadsheet','Callback',@plotterT.spreadsheetGUI);
        if isprop(plotterT,'fanDatasets')
            if isa(plotterT.fanDatasets,'nb_dataSource') && ~isempty(plotterT.fanDatasets)
                uimenu(gui.graphMenu,'Label','Spreadsheet Fan Data','Callback',@plotterT.spreadsheetFanDataGUI);
            end
        end
        uimenu(gui.graphMenu,'Label','Default Size','Callback',@gui.revertSize);
        uimenu(gui.graphMenu,'Label','Copy to Clipboard','Callback',@gui.copyToClipboard,'accelerator','Z');

        
    gui.propertiesMenu = uimenu(main,'label','Properties','enable','off');
        uimenu(gui.propertiesMenu,'Label','Plot type','Callback',@plotterT.selectPlotTypeGUI);
        uimenu(gui.propertiesMenu,'Label','Legend','Callback',@plotterT.legendGUI);
        uimenu(gui.propertiesMenu,'Label','Axes','Callback',@plotterT.axesPropertiesGUI);
        uimenu(gui.propertiesMenu,'Label','General','Callback',@plotterT.generalPropertiesGUI);

    % Create the menu of the figures
    %------------------------------------------------------
    varsOfFigs = cell(1,numOfGraphs);
    for ii = 1:numOfGraphs 
        start   = (ii - 1)*num + 1;
        finish  = ii*num;
        try  
            varsT = gui.vars(start:finish);  
        catch %#ok<CTCH>
            varsT = gui.vars(start:end);
        end
        varsOfFigs{ii} = varsT;
    end
    
    
    uimenu(graphs,'Label',toString(varsOfFigs{1}),'checked','on','Callback',@gui.changeGraph,'userdata',1);
    iter = min(numOfGraphs,30);
    for ii = 2:iter
        uimenu(graphs,'Label',toString(varsOfFigs{ii}),'Callback',@gui.changeGraph,'userdata',ii);
    end
    if nMenus > 1
        for ii = 2:nMenus
            iter = min(numOfGraphs - 30*(ii-1),30);
            for jj = 1:iter
                uimenu(menus.(['graphs' int2str(ii)]),'Label',toString(varsOfFigs{30*(ii-1) + jj}),...
                               'Callback',@gui.changeGraph,'userdata',30*(ii-1) + jj);
            end
        end
    end
       
    % Assign object the handel to the window
    %------------------------------------------------------
    gui.figureHandle = f;

    % Make the GUI visible.
    %------------------------------------------------------
    set(main,'Visible','on');
    
    % Plot
    %------------------------------------------------------
    
    % Set the figure handle of the new graph object
    % and some other settings
    gui.plotter.set('figureHandle',    f,...
                    'fontUnits',       'normalized',...
                    'legLocation',     'below');
                
    if ~isempty(gui.plotter.saveName) && gui.plotter.pdfBook
    
        for ii = 1:numOfGraphs
            
            start   = (ii - 1)*num + 1;
            finish  = ii*num;
            gui.plotter.variablesToPlot = varsOfFigs{ii};
            if ~isempty(gui.varsX)
                try  
                    varsXT = gui.varsX(start:finish);  
                catch %#ok<CTCH>
                    varsXT = gui.varsX(start:end);
                end
                gui.plotter.variableToPlotX = varsXT;
            end
            
            % Plot variables in the GUI window
            graphSubPlots(gui.plotter);
            
        end
        
        % Revert to the first variables to plot 
        gui.plotter.saveName = '';
        
        if numOfGraphs ~= 1
            
            try
                varsT = gui.vars(1:num);
            catch %#ok<CTCH>
                % Do nothing
            end
            gui.plotter.variablesToPlot = varsT;

            if ~isempty(gui.varsX)
                try  
                    varsXT = gui.varsX(1:num);  
                catch %#ok<CTCH>
                    % Do nothing
                end
                gui.plotter.variableToPlotX = varsXT;
            end

            % Plot variables in the GUI window
            graphSubPlots(gui.plotter);
            
        end
        
    else
        
        try
            varsT = gui.vars(1:num);
        catch %#ok<CTCH>
            % Do nothing
        end
        gui.plotter.variablesToPlot = varsT;
        
        if ~isempty(gui.varsX)
            try  
                varsXT = gui.varsX(1:num);  
            catch %#ok<CTCH>
                % Do nothing
            end
            gui.plotter.variableToPlotX = varsXT;
        end
        
        % Plot variables in the GUI window
        graphSubPlots(gui.plotter);
        
    end
    
    % Update some extra properties making it possible to edit the
    % legend
    setSpecial(plotterT,'graphMethod','graphSubPlots');
    updateLegendInformation(plotterT);
    
    % Enable menubar
    set(gui.graphMenu,'enable','on');
    set(gui.propertiesMenu,'enable','on'); 

end
