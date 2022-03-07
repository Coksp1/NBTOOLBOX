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
    
    if isempty(gui.position)
        gui.position = [40   15  186.4   43];
    end

    % Create the main window
    %------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
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

    % Set up the menu
    %------------------------------------------------------
    numOfGraphs = gui.plotter.DB.numberOfDatasets;
    if numOfGraphs < 1
        error([mfilename ':: Nothing to plot.'])
    end
    plotterT    = gui.plotter; 
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
        uimenu(gui.graphMenu,'Label','Spreadsheet','Callback',@plotterT.spreadsheetGUI);
        uimenu(gui.graphMenu,'Label','Default Size','Callback',@gui.revertSize);
        uimenu(gui.graphMenu,'Label','Copy to Clipboard','Callback',@gui.copyToClipboard,'accelerator','Z');
        
    gui.propertiesMenu = uimenu(main,'label','Properties','enable','off');
    gui.annotationMenu = uimenu(main,'label','Annotation','enable','off');
    addMenuComponents(gui.plotter,[],[],gui.propertiesMenu,gui.annotationMenu)    
       
    if strcmpi(gui.plotter.plotType,'dec')
        set(findobj(gui.propertiesMenu,'label','Legend'),'enable','off')
    end
    
    % Get number of variables plotted per figure
    %------------------------------------------------------
    gui.data = gui.plotter.DB;
    if isa(gui.plotter,'nb_table_cell')
        if iscell(gui.data)
            dataNames = nb_appendIndexes('Page ',1:size(gui.data,3));
        else
            dataNames = gui.data.dataNames;
        end
    else
        dataNames = gui.data.dataNames;
    end

    % Create the menu of the figures
    %------------------------------------------------------
    uimenu(graphs,'Label',dataNames{1},'checked','on','Callback',@gui.changeGraph,'userdata',1);
    iter = min(numOfGraphs,30);
    for ii = 2:iter
        uimenu(graphs,'Label',dataNames{ii},'Callback',@gui.changeGraph,'userdata',ii);
    end
    if nMenus > 1  
        for ii = 2:nMenus
            iter = min(numOfGraphs - 30*(ii-1),30);
            for jj = 1:iter
                uimenu(menus.(['graphs' int2str(ii)]),'Label',dataNames{30*(ii-1) + jj},'Callback',@gui.changeGraph,'userdata',30*(ii-1) + jj);
            end
        end
    end

    % Assign object the handel to the window
    %------------------------------------------------------
    gui.figureHandle = f;

    % Make the GUI visible.
    %------------------------------------------------------
    set(main,'Visible','on');
    
    % Plot graph(s)
    %------------------------------------------------------
    
    % Set the figure handle of the new graph object
    % and some other settings
    if isa(gui.plotter,'nb_graph')
        gui.plotter.set('figureHandle',    f,...
                        'fontUnits',       'normalized');
    else
        gui.plotter.setSpecial('figureHandle',    f,...
                               'fontUnits',       'normalized');
    end
    if ~isempty(gui.plotter.saveName) %&& gui.plotter.pdfBook
    
        for ii = 1:numOfGraphs
            gui.plotter.page = ii;
            graph(gui.plotter);
        end
        gui.plotter.saveName = '';
        
        % Switch to the first page
        if numOfGraphs ~= 1
            gui.plotter.page = 1;
            graph(gui.plotter);
        end
        
    else
        % Plot only the first page
        gui.plotter.page = 1;
        graph(gui.plotter);
    end
    
    % Get the legend information and set the colors property
    if isa(gui.plotter,'nb_graph')
        
        if ~strcmpi(gui.plotter.plotType,'dec')
            updateLegendInformation(gui.plotter);
        end
        if isempty(plotterT.colors)

            vars   = [plotterT.variablesToPlot, plotterT.variablesToPlotRight];
            colorO = plotterT.colorOrder;
            if iscell(colorO)
                colorO = nb_plotHandle.interpretColor(colorO);
            end

            colorOR = plotterT.colorOrderRight;
            if iscell(colorOR)
                colorOR = nb_plotHandle.interpretColor(colorOR);
            end

            colorO = [colorO; colorOR];
            colors = cell(1,length(vars)*2);
            for ii = 1:length(vars)
                colors{ii*2 - 1} = vars{ii};
                colors{ii*2    } = colorO(ii,:);
            end

            plotterT.colors = colors;

        end
        
    end

    % Enable menubar
    set(gui.graphMenu,'enable','on');
    set(gui.propertiesMenu,'enable','on'); 
    set(gui.annotationMenu,'enable','on'); 

end
