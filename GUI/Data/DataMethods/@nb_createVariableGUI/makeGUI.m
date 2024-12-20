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
        case 'variable'   
            figName = 'Create Variable';
            string  = 'Variable';
        case 'type'  
            figName = 'Create Type';
            string  = 'Type';
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
               'dockControls',   'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'normal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');

    % Add help menu
    help = uimenu('parent',            f,...
                  'label',             'Help',...
                  'callback',          @gui.helpCallback);
    
    % Make a create variable panel
    %--------------------------------------------------------------
    % Find the coordinate parameters
    extraSpace  = 0.04;
    space       = 0.02;
    totalSpace  = 0.02*6;
    buttonSpace = (1 - totalSpace)/5;

    % Make the editable cells
    uip = uipanel('parent',              f,...
                  'title',               figName,...
                  'units',               'normalized',...
                  'position',            [0.04 0.46 0.92 0.50]);

    uicontrol('units',              'normalized',...
              'position',           [0.02, buttonSpace*4 + space*5,0.96,buttonSpace],...
              'parent',             uip,...
              'style',              'text',...
              'string',             'Type in expression to be evaluated',...
              'horizontalAlignment','left');             

    gui.editbox1 = uicontrol(...
              'units',              'normalized',...
              'position',           [0.02, buttonSpace*3 + space*4 + extraSpace,0.96,buttonSpace],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'horizontalAlignment','left');         

    uicontrol('units',              'normalized',...
              'position',           [0.02, buttonSpace*2 + space*3,0.96,buttonSpace],...
              'parent',             uip,...
              'style',              'text',...
              'string',             ['Type in name of ' lower(string) ' (optional)'],...
              'horizontalAlignment','left');             

    gui.editbox2 = uicontrol(...
              'units',              'normalized',...
              'position',           [0.02, buttonSpace*1 + space*2 + extraSpace,0.96,buttonSpace],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'horizontalAlignment','left'); 

    uicontrol('units',              'normalized',...
              'position',           [0.02, space,0.96,buttonSpace],...
              'parent',             uip,...
              'style',              'pushbutton',...
              'string',             'Create',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'callback',           @gui.createVariableCallback);
          
    %Create help panel
    uip2 = uipanel('parent',              f,...
                   'visible',             'off',...
                   'borderType',          'none',...
                   'units',               'normalized',...
                   'position',            [0 0 1 1]);
    
    %Create textbox
    uicontrol('units',              'normalized',...
              'position',           [0.04, 0.85,0.24,0.09],...
              'parent',             uip2,...
              'style',              'text',...
              'string',             'Functions',...
              'horizontalAlignment','left');
          
    %Find the object type
    type = class(gui.data);
    
    list = nb_createVariableGUI.funclist(type);
    helpText = nb_createVariableGUI.helpOn(list{1,1});
    
    %Create popupmenu
    uicontrol('units',              'normalized',...
              'position',           [0.32, 0.85,0.44,0.11],...
              'parent',             uip2,...
              'style',              'popupmenu',...
              'string',             list,...
              'background',         [1 1 1],...
              'callBack',           @gui.updateHelp,...
              'horizontalAlignment','left');
          
    %Create help text
    gui.textboxHelp = uicontrol('units',              'normalized',...
                                'position',           [0.04, 0.04,0.92,0.77],...
                                'parent',             uip2,...
                                'style',              'text',...
                                'string',             helpText,...
                                'horizontalAlignment','left');

    % Make GUI visible
    set(f,'visible','on');
    
    gui.panel1 = uip;
    gui.panel2 = uip2;
    gui.help   = help;

end
