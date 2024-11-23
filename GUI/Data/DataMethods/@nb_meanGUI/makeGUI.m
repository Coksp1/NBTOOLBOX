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
    
    string = [upper(gui.type(1)), lower(gui.type(2:end))];

    if isa(mainGUI,'nb_GUI')
        name = [mainGUI.guiName ': ' string];
    else
        name = string;
    end
    
    % Create window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  70   17],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Find the coordinate parameters
    startX          = 0.14;
    width           = 1 - startX*2;
    height          = 0.09;
    listExtraHeight = 0.02;

    % Select dimension
    %--------------------------------------------------------------
    uicontrol('units',              'normalized',...
              'position',           [startX, 0.77,width,height],...
              'parent',             f,...
              'style',              'text',...
              'string',             'Select Dimension',...
              'horizontalAlignment','left');             

    list = {'1','2','3'};
    
    gui.popupmenu1 = uicontrol(...
                     'units',              'normalized',...
                     'position',           [startX, 0.65,width,height + listExtraHeight],...
                     'parent',             f,...
                     'background',         [1 1 1],...
                     'style',              'popupmenu',...
                     'string',             list,...
                     'horizontalAlignment','left'); 
                 
    % Output type
    %--------------------------------------------------------------
    uicontrol('units',              'normalized',...
              'position',           [startX, 0.45,width,height],...
              'parent',             f,...
              'style',              'text',...
              'string',             'Output',...
              'horizontalAlignment','left');             

    if isa(gui.data,'nb_ts')
        list = {'Time-Series','Cross-Sectional'}; 
    elseif isa(gui.data,'nb_data')
        list = {'Dimensionless','Cross-Sectional'}; 
    else
        list = {'Cross-Sectional'}; 
    end
          
    gui.popupmenu2 = uicontrol(...
                     'units',             'normalized',...
                     'position',           [startX, 0.36,width,height + listExtraHeight],...
                     'parent',             f,...
                     'background',         [1 1 1],...
                     'style',              'popupmenu',...
                     'string',             list,...
                     'horizontalAlignment','left'); 
                 
    % Pushbutton
    %--------------------------------------------------------------
    buttonWidth  = 0.25;
    buttonHeigth = 0.13;
    uicontrol(...
        'units',            'normalized',...
        'position',         [0.5 - buttonWidth/2, (0.30 - buttonHeigth)/2,buttonWidth,buttonHeigth],...
        'parent',           f,...
        'style',            'pushbutton',...
        'Interruptible',    'off',...
        'busyAction',       'cancel',...
        'string',           'Calculate',...
        'callback',         @gui.meanCallback);

    % Make GUI visible
    set(f,'visible','on');

end
