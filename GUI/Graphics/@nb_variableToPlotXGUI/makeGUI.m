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

    parent  = gui.plotter.parent;

    % Create the main window
    %--------------------------------------------------------------
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': X-Tick Variable'];
    else
        name = 'X-Tick Variable';
    end
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  60   9],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Find the coordinate parameters
    startX          = 0.3;
    startXNames     = 0.08; 
    width           = 1 - startX*2;
    widthNames      = 1 - startXNames*2;
    height          = 0.18;
    listExtraHeight = 0.04;

    uicontrol('units',              'normalized',...
              'position',           [startX, 0.65,width,height],...
              'parent',             f,...
              'style',              'text',...
              'string',             'Select X-tick Variable',...
              'horizontalAlignment','left');             

    vars  = [{''},gui.plotter.DB.variables];
    value = find(strcmp(gui.plotter.variableToPlotX,vars));
    gui.popupmenu = uicontrol(...
                     'units',             'normalized',...
                     'position',           [startXNames, 0.45,widthNames,height + listExtraHeight],...
                     'parent',             f,...
                     'background',         [1 1 1],...
                     'style',              'popupmenu',...
                     'string',             vars,...
                     'value',              value);         

    buttonWidth  = 0.3;
    buttonHeigth = 0.2;
    uicontrol('units',       'normalized',...
              'position',    [0.5 - buttonWidth/2, (0.45 - buttonHeigth)/2,buttonWidth,buttonHeigth],...
              'parent',      f,...
              'style',       'pushbutton',...
              'string',      'Select',...
              'callback',    @gui.selectVarXCallback);

    % Make GUI visible
    set(f,'visible','on');

end
