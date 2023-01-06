function makeGUI(gui,includeCancel)
% Syntax:
%
% makeGUI(gui,includeCancel)
%
% Description:
%
% Make GUI.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    parent = gui.parent;

    % Create the main window
    %--------------------------------------------------------------
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': ' gui.name];
    else
        name = gui.name;
    end
    
    if strcmpi('docked',get(0,'defaultFigureWindowStyle'))
        dockControls = 'on';
    else
        dockControls = 'off';
    end

    % Create the window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure(  'Visible',     'off',...
                 'Color',       defaultBackground,...
                 'units',       'characters',...
                 'position',    [50 40 100 20],...
                 'name',        name,...
                 'NumberTitle', 'off',...
                 'MenuBar',     'None',...
                 'Toolbar',     'None',...
                 'resize',      'off',...
                 ...'windowStyle', 'modal',...
                 'dockControls',dockControls);
    gui.figureHandle = f;         
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % A text box for messages
    gui.textBox = uicontrol(...
              'parent',             f,...
              'units',              'normal',...
              'Style',              'text',...
              'fontSize',           10,...
              'String',             '',...
              'visible',            'off');
    
    % Create a axes to "plot" the waiting bar on
    gui.ax = axes(...
         'parent',             f,...
         'units',              'normal',...
         'box',                'on',...
         'yLim',               [0,1],...
         'xLim',               [0,1],...
         'xTick',              [],...
         'yTick',              [],...
         'visible',            'off');
     
    % A text box for messages
    gui.textBox2 = uicontrol(...
              'parent',             f,...
              'units',              'normal',...
              'Style',              'text',...
              'fontSize',           10,...
              'String',             '',...
              'visible',            'off');
    
    % Create a axes to "plot" the waiting bar on
    gui.ax2 = axes(...
         'parent',             f,...
         'units',              'normal',...
         'box',                'on',...
         'yLim',               [0,1],...
         'xLim',               [0,1],...
         'xTick',              [],...
         'yTick',              [],...
         'visible',            'off');
                     
    if includeCancel
     
        % A text box for messages
        gui.cancelButton = uicontrol(...
                  'parent',             f,...
                  'units',              'normal',...
                  'position',           [0.4,0.1,0.2,0.1],...
                  'style',              'pushbutton',...
                  'string',             'Cancel',...
                  'callback',           @gui.cancelCallback); 
              
    end
     
    % Make it visible
    set(f,'visible','on')

end
