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

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty. Nothing to reorder.')
        return
    end

    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  70   30],...
               'Color',          defaultBackground,...
               'name',           [gui.parent.guiName ': Reorder Package'],...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'windowStyle',    'modal',...
               'resize',         'off');
    gui.figureHandle = f; 
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Panel with graph selection list
    xSpace     = 0.04;
    ySpace     = 0.04;   
    startY     = 0.32;
    listWidth  = 0.44;
    heightY    = 1 - startY - ySpace;
    uip = uipanel('parent',              f,...
                  'title',               'Select Graph',...
                  'units',               'normalized',...
                  'position',            [xSpace, startY, listWidth, heightY]);
    
    % List of graph names
    graphNames = gui.package.identifiers;
    gui.listbox = uicontrol(...
                     'units',       'normalized',...
                     'position',    [0.04, 0.02, 0.92, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      graphNames,...
                     'max',         1,...
                     'callback',    @gui.changeSelectedGraph);
                 
    % Find how to locate the pushbuttons
    numberOfButtons = 4;
    width           = 0.2;
    height          = 0.06;
    yButtonSpace    = 0.02;
    startButtons    = startY + heightY/2 + height*(numberOfButtons/2 - 1) + yButtonSpace*floor(numberOfButtons/2);
    startXButtons   = (listWidth + 1 - width)/2;
    kk              = 0;
                                  
    % Create move down button
    uicontrol('units',          'normalized',...
              'position',       [startXButtons, startButtons - kk*(yButtonSpace + height), width, height],...
              'parent',         f,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'string',         'Move Down',...
              'callback',       @gui.moveDownCallback); 
          
    % Create move up button
    kk = kk + 1;
    uicontrol('units',          'normalized',...
              'position',       [startXButtons, startButtons - kk*(yButtonSpace + height), width, height],...
              'parent',         f,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'string',         'Move Up',...
              'callback',       @gui.moveUpCallback); 
    
    % Create move first button
    kk = kk + 1;
    uicontrol('units',          'normalized',...
              'position',       [startXButtons, startButtons - kk*(yButtonSpace + height), width, height],...
              'parent',         f,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'string',         'Move First',...
              'callback',       @gui.moveFirstCallback);        
          
    % Create move last button
    kk = kk + 1;
    uicontrol('units',          'normalized',...
              'position',       [startXButtons, startButtons - kk*(yButtonSpace + height), width, height],...
              'parent',         f,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'string',         'Move Last',...
              'callback',       @gui.moveLastCallback);       
       
    % Get the first graph object      
    %---------------------------
    graphTemp  = gui.package.graphs{1};
    figNameNor = graphTemp.figureNameNor;
    figNameEng = graphTemp.figureNameEng;
    
    % Locations
    textHeight    = 0.04;
    editBoxHeight = 0.06;
    textWidth     = 1 - xSpace*2;
    
    % Norwegian
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [xSpace, startY - yButtonSpace - textHeight, textWidth, textHeight],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Norwegian Figure Name');

    gui.editbox1 = uicontrol(...
              'units',              'normalized',...
              'position',           [xSpace, startY - yButtonSpace - textHeight - editBoxHeight, textWidth, editBoxHeight],...
              'parent',             f,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','left',...
              'string',             figNameNor); 
          
    % English
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [xSpace, startY - yButtonSpace*2 - textHeight*2 - editBoxHeight, textWidth, 0.04],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'English Figure Name');

    gui.editbox2 = uicontrol(...
              'units',              'normalized',...
              'position',           [xSpace, startY - yButtonSpace*2 - textHeight*2 - editBoxHeight*2, textWidth, editBoxHeight],...
              'parent',             f,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','left',...
              'string',             figNameEng);
    
          
    % Make it visible
    set(f,'visible','on')

end
