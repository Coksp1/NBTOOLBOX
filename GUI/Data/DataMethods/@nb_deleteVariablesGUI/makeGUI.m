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

    % Get the handle to the main program
    mainGUI = gui.parent;

   % Decide the window name
    switch lower(gui.type)
        case 'variables'   
            figName = 'Delete Variables';
            string  = 'Variables';
        case 'types'  
            figName = 'Delete Types';
            string  = 'Types';
    end
    
    if isa(mainGUI,'nb_GUI')
        name = [mainGUI.guiName ': ' figName];
    else
        name = figName;
    end
    
    % Create window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  70   30],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    gui.figureHandle = f;
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Make a delete variables panel
    %--------------------------------------------------------------
    variables = gui.data.variables;

    switch lower(gui.type)
        case 'variables'   
            variables = gui.data.variables;
        case 'types'  
            variables = gui.data.types;
    end
    
    
    % Panel with model selection list
    uip = uipanel('parent',              f,...
                  'title',               ['Delete ' string],...
                  'units',               'normalized',...
                  'position',            [0.04, 0.04, 0.44, 0.92]);

    % List datasets
    gui.listbox = uicontrol(...
                     'units',       'normalized',...
                     'position',    [0.02, 0.02, 0.96, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      variables,...
                     'max',         size(variables,2)); 

    % Create load button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',              'normalized',...
              'position',           [0.5 + 0.25 - width/2 - 0.01, 0.4, width, height],...
              'parent',             f,...
              'background',         defaultBackground,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'string',             'Delete',...
              'callback',           @gui.deleteCallback); 

    % Make it visible
    set(f,'visible','on')

end
