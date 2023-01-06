function updateGUI(gui)
% Syntax:
%
% updateGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(gui.graphMenu)
        delete(gui.graphMenu);
    end
    if ~isempty(gui.dataMenu)
        delete(gui.dataMenu);
    end
    if ~isempty(gui.propertiesMenu)
        delete(gui.propertiesMenu);
    end
    if ~isempty(gui.annotationMenu)
        delete(gui.annotationMenu);
    end
    
    % Set up the menu
    %------------------------------------------------------
    main          = gui.figureHandle.figureHandle;
    plotterT      = gui.plotter(gui.page);
    numOfGraphs   = length(gui.plotter);
    gui.graphMenu = uimenu(main,'label','File','enable','off');
        sep = 'off';
        if isa(plotterT.parent,'nb_GUI')
            sep = 'on';
            uimenu(gui.graphMenu,'Label','Save as (only this page)','Callback',@gui.saveAs);
        end
        graphs = uimenu(gui.graphMenu,'Label','Graphs','separator',sep);
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
        uimenu(gui.graphMenu,'Label','Default Size','Callback',@gui.revertSize);
        uimenu(gui.graphMenu,'Label','Copy to Clipboard','Callback',@gui.copyToClipboard,'accelerator','Z');
      
    gui.dataMenu       = uimenu(main,'label','Data','enable','off');    
    gui.propertiesMenu = uimenu(main,'label','Properties','enable','off');    
    gui.annotationMenu = uimenu(main,'label','Annotation','enable','off');
        
    % Create the menu of the figures
    %------------------------------------------------------
    iter = min(numOfGraphs,30);
    for ii = 1:iter
        addOneGraphToMenu(gui,graphs,ii);
    end
    if nMenus > 1  
        for ii = 2:nMenus
            iter = min(numOfGraphs - 30*(ii-1),30);
            for jj = 1:iter
                addOneGraphToMenu(gui,menus.(['graphs' int2str(ii)]),30*(ii-1) + jj);
            end
        end
    end
    
    addMenuComponents(plotterT,gui.graphMenu,gui.dataMenu,gui.propertiesMenu,gui.annotationMenu);

    % Plot graph(s)
    %------------------------------------------------------
    
    % Set the figure handle of the new graph object
    % and some other settings
    plotterT.setSpecial('figureHandle',    gui.figureHandle,...
                        'axesHandle',      gui.axesHandle);
    plotterT.set('fontUnits','normalized');         
    
    % Add context menu
    % Create context menu of panel
    %------------------------------------------------------
    if isa(plotterT.parent,'nb_GUI')
        
        if ~isempty(gui.axesContextMenu)
            if ishandle(gui.axesContextMenu)
                delete(gui.axesContextMenu);
            end
        end
        
        cMenu = uicontextmenu(); 
            uimenu(cMenu,'Label','Copy','Callback',@gui.copy);
            clipMenu = uimenu(cMenu,'Label','Copy to Clipboard');
                uimenu(clipMenu,'Label','As figure','Callback',@gui.copyToClipboard);
                uimenu(clipMenu,'Label','As data','Callback',@gui.copyToClipboardAsData);
        gui.axesContextMenu = cMenu;
        plotterT.setSpecial('UIContextMenu',cMenu);
        
    end
    
    % Plot the selected graph
    graph(plotterT);
    gui.axesHandle = get(plotterT,'axesHandle');
    
    % Enable menubar
    set(gui.graphMenu,'enable','on');
    set(gui.dataMenu,'enable','on');
    set(gui.propertiesMenu,'enable','on'); 
    set(gui.annotationMenu,'enable','on'); 
     
end

%==========================================================================
function addOneGraphToMenu(gui,graphs,ii)

    if isempty(gui.plotter(ii).title)
        label = ['Graph' int2str(ii)];
    else
        if iscell(gui.plotter(ii).title)
            label = ['Graph' int2str(ii)];
        else
            label = gui.plotter(ii).title;
        end
    end
    if ii == gui.page
        uimenu(graphs,'Label',label,'checked','on','Callback',@gui.changeGraph,'userdata',ii);
    else
        uimenu(graphs,'Label',label,'Callback',@gui.changeGraph,'userdata',ii);
    end

end
