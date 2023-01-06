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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the handle to the main program
    mainGUI = gui.parent;

    % Decide the window name
    figName = 'Permute';
    
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
               'position',       [65,   15,  60,   15],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
         
    uicontrol(...
              'units',                  'normalized',...
              'position',               [0.05, 0.5, 0.9, 0.2],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Are you sure you want to permute the data?');             
     
    % Calculate button
    %--------------------------------------------------------------
    buttonHeight = 0.13;
    buttonWidth  = 0.35;
    buttonXLoc   = 0.5 - buttonWidth/2;
    buttonYLoc   = (0.5 - buttonHeight)/2;
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
              'parent',             f,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'string',             'Yes',...
              'callback',           @gui.okCallback);   

    % Make GUI visible
    set(f,'visible','on');

end
