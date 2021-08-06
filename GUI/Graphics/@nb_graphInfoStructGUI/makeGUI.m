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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

    % Create the main window
    %------------------------------------------------------
    currentMonitor = nb_getCurrentMonitor();
    f    = nb_graphPanel('[4,3]',...
                         'visible',        'off',...
                         'units',          'characters',...
                         'position',       [40   15  186.4   45],...
                         'Color',          [1 1 1],...
                         'name',           name,...
                         'numberTitle',    'off',...
                         'dockControls',   'off',...
                         'menuBar',        'None',...
                         'toolBar',        'None',...
                         'tag',            'main');
    main = f.figureHandle;                 
    nb_moveFigureToMonitor(main,currentMonitor,'center');      

    % Get the plotter object
    %------------------------------------------------------
    plotterT = gui.plotter;
    
    % Get number of graphs
    %------------------------------------------------------
    gui.GraphStruct = gui.plotter.GraphStruct;
    fnames          = fieldnames(gui.GraphStruct);
    numOfGraphs     = length(fnames);
    if isempty(fnames)
        nb_errorWindow('Nothing to plot.')
        return
    end
    
    % Set up the menu
    %------------------------------------------------------
    gui.graphMenu = uimenu(main,'label','File','enable','off');
        graphs = uimenu(gui.graphMenu,'Label','Graphs');
        nMenus = ceil(numOfGraphs/30);
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
        uimenu(gui.graphMenu,'Label','Spreadsheet','Callback',@gui.spreadsheet);
        if isa(plotterT.fanDatasets,'nb_dataSource') && ~isempty(plotterT.fanDatasets)
            uimenu(gui.graphMenu,'Label','Spreadsheet Fan Data','Callback',@gui.spreadsheetFanData);
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
    uimenu(graphs,'Label',fnames{1},'checked','on','Callback',@gui.changeGraph);
    iter = min(numOfGraphs,30);
    for ii = 2:iter
        uimenu(graphs,'Label',fnames{ii},'Callback',@gui.changeGraph);
    end
    
    if nMenus > 1  
        for ii = 2:nMenus
            iter = min(numOfGraphs - 30*(ii-1),30);
            for jj = 1:iter
                uimenu(menus.(['graphs' int2str(ii)]),'Label',fnames{30*(ii-1) + jj},'Callback',@gui.changeGraph);
            end
        end
    end
    
    % Assign object the handle to the window
    %------------------------------------------------------
    gui.figureHandle = f;

    % Make the GUI visible.
    %------------------------------------------------------
    set(main,'Visible','on');
    
    % Plot the graph(s)
    %------------------------------------------------------
    if ~isempty(gui.plotter.saveName) && gui.plotter.pdfBook
    
        % We must loop through all graphs to print them to the
        % pdf
        gui.plotter.set('figureHandle',    f,...
                        'fontUnits',       'normalized',...
                        'legLocation',     'below');
                    
        for ii = 1:length(fnames)
            
            tempInfoStruct              = struct();
            tempInfoStruct.(fnames{ii}) = gui.GraphStruct.(fnames{ii});
            gui.plotter.GraphStruct     = tempInfoStruct;
            graphInfoStruct(gui.plotter);
            
        end
        
        % We move to the first graph, and set the saveName propety
        % to empty so nothing more is printed
        gui.plotter.saveName = '';
        if length(fnames) ~= 1
            tempInfoStruct             = struct();
            tempInfoStruct.(fnames{1}) = gui.GraphStruct.(fnames{1});
            gui.plotter.GraphStruct    = tempInfoStruct;
            graphInfoStruct(gui.plotter);
        end
        
    else
        
        % Get the first structure to plot
        tempInfoStruct = struct();
        tempInfoStruct.(fnames{1}) = gui.GraphStruct.(fnames{1});

        % Set the figure handle of the new graph object
        % and some other settings
        gui.plotter.set('figureHandle',    f,...
                        'fontUnits',       'normalized',...
                        'graphStruct',     tempInfoStruct,...
                        'legLocation',     'below',...
                        'saveName',        '');

        % Plot variables in the GUI window
        graphInfoStruct(gui.plotter);
        
    end
    
    % Enable menubar
    set(gui.graphMenu,'enable','on');
    set(gui.propertiesMenu,'enable','on'); 

end
