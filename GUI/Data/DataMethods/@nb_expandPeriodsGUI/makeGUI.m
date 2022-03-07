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

    % Get the handle to the main program
    mainGUI = gui.parent;
    figName = 'Expand by N periods';   
    
    % Create window
    if isa(mainGUI,'nb_GUI')
        name = [mainGUI.guiName ': ' figName];
    else
        name = figName;
    end
    
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65,   15,  40,   10],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Locations
    %--------------------------------------------------------------
    numOfRows       = 3;
    marginY         = 0.15;
    rowHeight       = (1 - marginY*(numOfRows-1)) / numOfRows;
    spaceX          = 0.04;
    
    % Container panel
    container = uipanel(f,...
        'BorderWidth', 0,...
        'position', [0 marginY 1 (1 - 2*marginY)]);
    
    % Start date
    uicontrol(...
              'units',                  'normalized',...
              'position',               [spaceX, 2*(rowHeight + marginY), 0.7, rowHeight],...
              'parent',                 container,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Number of periods');
    
    gui.numOfPeriodsBox = uicontrol(...
              'units',                  'normalized',...
              'position',               [0.7, 2*(rowHeight + marginY), 0.3 - spaceX, rowHeight],...
              'parent',                 container,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'left',...
              'Interruptible',          'off',...
              'string',                 '1');
   
    % Type
    uicontrol(...
              'units',                  'normalized',...
              'position',               [spaceX, rowHeight + marginY, 0.5, rowHeight],...
              'parent',                 container,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Type');
    
    gui.typePopOptions = {'nan' 'zeros' 'ones' 'rand' 'obs'};  
    options = {'NaN' '0' '1' 'Random' 'First/last observation'};    
    gui.typePop = uicontrol(...
              'units',              'normalized',...
              'position',           [0.5, rowHeight + marginY, 0.5-spaceX, rowHeight],...
              'parent',             container,...
              'background',         [1 1 1],...
              'style',              'popupmenu',...
              'Interruptible',      'off',...
              'string',             options,...
              'value',              1);             
     
    % Calculate button
    %--------------------------------------------------------------
    uicontrol(...
              'units',              'normalized',...
              'position',           [spaceX*2, 0, 1-spaceX*4, rowHeight],...
              'parent',             container,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'string',             'OK',...
              'callback',           {@gui.expandPeriodsCallback, f});   

    % Make GUI visible
    set(f,'visible','on');

end
