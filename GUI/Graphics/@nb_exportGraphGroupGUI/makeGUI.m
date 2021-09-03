function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Creates the menu for exporting graph groups.
% With the main window of DAG open: Graphics > Export graph group
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % List of graphs
    %--------------------------------------------------------------
    appGraphs  = gui.parent.graphs;
    graphNames = fieldnames(appGraphs);

    if isempty(graphNames)
        nb_errorWindow('There are no stored graph objects to export.')
        return
    end
    
    parent = gui.parent;
    name   = 'Export Graph Group';
    
    % Creating the main window
    %--------------------------------------------------------------   
    f = nb_guiFigure(parent,name,[40   15  90   20],'modal','off');
    gui.figureHandle = f;          
    
    % Locations
    %--------------------------------------------------------------
    xSpace       = 0.04;
    ySpace       = 0.04;
    yStartP1     = 0.78;
    yHeightP1    = 1 - yStartP1 - ySpace;
    xWidthP1     = 1 - xSpace*2;
    buttonHeight = 0.09;
    buttonWidth  = 0.2;
    
    % File name/path panel
    %--------------------------------------------------------------
    uip = uipanel(...
        'parent',       f,...
        'units',        'normalized',...
        'position',     [xSpace,yStartP1,xWidthP1,yHeightP1],...
        'title',        'File Name/Path');
    
    xPanelSpace = 0.02;
    yPanelSpace = 0.15;
    xPanelEdit  = 0.7;
    gui.edit1 = uicontrol(...
              'units',                  'normalized',...
              'position',               [xPanelSpace, yPanelSpace, xPanelEdit, 1 - yPanelSpace*2],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'left',...
              'string',                 '');
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [xPanelEdit + xPanelSpace*2, yPanelSpace, 1 - xPanelEdit - xPanelSpace*3, 1 - yPanelSpace*2],...
              'parent',         uip,...
              'style',          'pushbutton',...
              'string',         'Browse',...
              'callback',       @gui.browse);
          
    % Options Panel
    %--------------------------------------------------------------
    uip = uipanel(...
        'parent',       f,...
        'units',        'normalized',...
        'position',     [xSpace,ySpace*2 + buttonHeight,xWidthP1,yStartP1 - ySpace*3 - buttonHeight],...
        'title',        'Options');
    
    % Panel locations
    gui.list1 = uicontrol(...
              'units',                  'normalized',...
              'position',               [0.05, 0.05, 0.9, 0.9],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'listbox',...
              'horizontalAlignment',    'left',...
              'string',                 graphNames,...
              'max',                    length(graphNames));
          
    % OK button
    %--------------------------------------------------------------
    uicontrol(...
      'units',          'normalized',...
      'position',       [0.5 - xSpace/2 - buttonWidth, ySpace, buttonWidth, buttonHeight],...
      'parent',         f,...
      'style',          'pushbutton',...
      'Interruptible',  'off',...
      'string',         'OK',...
      'callback',       @gui.saveToFile);
  
    % Cancel button
    %--------------------------------------------------------------
    uicontrol(...
      'units',          'normalized',...
      'position',       [0.5 + xSpace/2, ySpace, buttonWidth, buttonHeight],...
      'parent',         f,...
      'style',          'pushbutton',...
      'Interruptible',  'off',...
      'string',         'Cancel',...
      'callback',       @gui.cancel);
  
   % Make it visible
   %---------------------------------------------------------------
   set(f,'visible','on');
          
end