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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Check if there is something to display
    [gui.sources,gui.tableData] = getMethodCalls(gui.data);
    if isempty(gui.sources{1})
        nb_errorWindow('The dataset is not updateable, so no method list to display')
        delete(gui)
        return
    end

    % Create the main window
    %------------------------------------------------------
    parent = gui.parent;
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Method calls'];
    else
        name = 'Method calls';
    end
    
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f    = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [40   15  85.5   31.5],...
                  'Color',          defaultBackground,...
                  'name',           name,...
                  'numberTitle',    'off',...
                  'dockControls',   'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'on',...
                  'windowStyle',    'modal');               
    gui.figureHandle = f;
    nb_moveFigureToMonitor(f,currentMonitor,'center');

    % Create list box with different sources
    %--------------------------------------------------------------
    gui.list = uicontrol('units',       'normalized',...
                         'position',    [0.1, 0.85, 0.8, 0.1],...
                         'parent',      f,...
                         'background',  [1 1 1],...
                         'style',       'popupmenu',...
                         'string',      gui.sources,...
                         'max',         1,...
                         'callback',    @gui.updateGUI);
    
    % Create table with method calls
    %--------------------------------------------------------------
    s2          = size(gui.tableData,2);
    colNames    = cell(1,s2);
    colNames{1} = 'Name';
    colEdit     = true(1,s2);
    colEdit(1)  = false;
    colForm     = cell(1,s2);
    colForm(:)  = {'char'};
    t = nb_uitable(...
            gui.figureHandle,...
            'units',                'normalized',...
            'position',             [0 0.1 1 0.7],...
            'columnName',           colNames,...
            'columnFormat',         colForm,...
            'columnEdit',           colEdit,...
            'cellEditCallback',     @gui.cellEdit,...
            'cellSelectionCallback',@gui.getSelectedCells);

    gui.table = t;

    % Update button
    %--------------------------------------------------------------
    buttonWidth  = 0.2;
    buttonHeight = 0.05;
    uicontrol('units',       'normalized',...
              'position',    [0.5 - buttonWidth/2, 0.05 - buttonHeight/2, buttonWidth, buttonHeight],...
              'parent',      f,...
              'style',       'pushbutton',...
              'string',      'Update',...
              'callback',    @gui.updateCallback);
    
    % Add context menu to table
    %--------------------------------------------------------------
    cMenu = uicontextmenu('parent',gui.figureHandle);
        uimenu(cMenu,'Label','Help','Callback',@gui.methodHelp);
        uimenu(cMenu,'Label','Delete','Callback',@gui.deleteRow);
    set(t,'UIContextMenu',cMenu);
    
    gui.updateGUI();
    
    set(f,'visible','on')
    
end
