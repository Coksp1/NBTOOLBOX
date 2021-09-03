function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Creates the menu for General Properties.
% With a graph open: Properties > General.
% 
% Written by Kenneth S�terhagen Paulsen
        
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Create the main window
    %------------------------------------------------------
    parent = gui.plotter.parent;
    name   = 'General Properties';
    
    f = nb_guiFigure(parent,name,[40   15  85.5   33.5],'modal','off');
    gui.figureHandle = f;

    
    % Set up panel
    %------------------------------------------------------
    uib = uibuttongroup('parent',              f,...
                        'title',               '',...
                        'background',          [1 1 1],...
                        'Interruptible',       'off',...
                        'units',               'normalized',...
                        'position',            [0.02 0.02 0.18 0.96],...
                        'SelectionChangeFcn',  @gui.changePanel); 

    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.90, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'Plot'); 

    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.80, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'Baseline');
    
    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.70, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'Text');
    
    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.60, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'Missing'); 
    
    uicontrol(...
        'units',       'normalized',...
        'position',    [0, 0.50, 1, 0.1],...
        'background',  [1 1 1],...   
        'parent',      uib,...
        'style',       'togglebutton',...
        'string',      'Look up');

    % Make sub-windows
    %------------------------------------------------------
    plotPanel(gui)
    missingPanel(gui)
    baselinePanel(gui)
    textPanel(gui)
    lookUpMatrixPanel(gui)
        
    % Set the window visible
    %------------------------------------------------------
    set(f,'visible','on');

end