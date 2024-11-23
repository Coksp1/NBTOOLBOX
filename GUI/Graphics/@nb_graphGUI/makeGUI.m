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

    % Find positions
    %--------------------------------------------------------------
    pos = gui.parent.settings.graphSettings.(gui.template).figurePosition;
    if isa(gui.parent,'nb_GUI')
        name = [gui.parent.guiName ': Graphics'];
    else
        name = 'Graphics';
    end
    
    % Create the main window
    %------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    f    = nb_graphPanel(gui.parent.settings.graphSettings.(gui.template).plotAspectRatio,...
                         'advanced',       strcmpi(gui.type,'advanced'),...
                         'renderer',       'painters',...
                         'visible',        'off',...
                         'units',          'characters',...
                         'position',       pos,...
                         'Color',          [1 1 1],...
                         'name',           name,...
                         'numberTitle',    'off',...
                         'dockControls',   'off',...
                         'menuBar',        'None',...
                         'toolBar',        'None',...
                         'tag',            'nb_graphGUI',...
                         'CloseRequestFcn',@gui.close);
    main = f.figureHandle;                 
    nb_moveFigureToMonitor(main,currentMonitor,'center');

    % Set up the menu
    %------------------------------------------------------
    gui.graphMenu = uimenu(main,'label','File','enable','off');
        uimenu(gui.graphMenu,'Label','Save','Callback',@gui.save);
        uimenu(gui.graphMenu,'Label','Save as','Callback',@gui.saveAs);
        uimenu(gui.graphMenu,'Label','Rename','separator','on','Callback',@gui.renameGraph);
        uimenu(gui.graphMenu,'Label','Export','separator','on','Callback',@gui.export);
        uimenu(gui.graphMenu,'Label','Print','Callback',@gui.printFigure);
        uimenu(gui.graphMenu,'Label','Redraw','Callback',@gui.updateGraph);
        uimenu(gui.graphMenu,'Label','Default Size','Callback',@gui.revertSize);
        uimenu(gui.graphMenu,'Label','Preview','Callback',@gui.previewSingleGraph);
        uimenu(gui.graphMenu,'Label','Help','separator','on','Callback',@gui.helpFileCallback);

    dataM = uimenu(main,'label','Data');
    uimenu(dataM,'Label','Load Dataset','Callback',@gui.loadData);
    gui.dataMenu = dataM;

    gui.propertiesMenu = uimenu(main,'label','Properties','enable','off');   

    gui.annotationMenu = uimenu(main,'label','Annotation','enable','off');   

    gui.languageMenu = uimenu(main,'label','Language','enable','off');
        uimenu(gui.languageMenu,'Label','English','Callback',@gui.setToEnglish,'checked','on');
        uimenu(gui.languageMenu,'Label','Norwegian','Callback',@gui.setToNorwegian,'checked','off');
    
    gui.advancedMenu = uimenu(main,'label','Advanced','enable','off'); 
        
    gui.templateMenu = uimenu(main,'label','Template','enable','off');
        uimenu(gui.templateMenu,'Label','New...','Callback',@gui.newTemplateCallback);
        uimenu(gui.templateMenu,'Label','Choose...','Callback',@gui.setTemplateCallback);
        uimenu(gui.templateMenu,'Label','Save','Callback',@gui.saveTemplateCallback);
        uimenu(gui.templateMenu,'Label','Help','Callback',@gui.helpTemplateCallback,'separator','on');
    
    if isa(gui.parent,'nb_GUI')
        parent   = gui.parent;
        callback = @parent.helpinDAGCallback;
    else
        callback = [];
    end
    
    gui.helpMenu = uimenu(main,'label','Help');
        uimenu(gui.helpMenu,'Label','General','Callback',callback);

    % Add context menu to the figure. So the user can paste in
    % a graph object or a data object (also data from the 
    % clipboard)
    if gui.contextMenu    
        cMenu  = uicontextmenu('parent',main);
            uimenu(cMenu,'Label','Paste','Callback',{@gui.paste,'local'});
            uimenu(cMenu,'Label','Paste from Clipboard (.)','Callback',{@gui.paste,'.'});
            uimenu(cMenu,'Label','Paste from Clipboard (,)','Callback',{@gui.paste,','});
        set(f.panelHandle,'UIContextMenu',cMenu); 
    end
    
    % Assign object the handle to the window
    %------------------------------------------------------
    gui.figureHandle = f;

    % Make the GUI visible.
    %------------------------------------------------------
    set(main,'Visible','on');

end
