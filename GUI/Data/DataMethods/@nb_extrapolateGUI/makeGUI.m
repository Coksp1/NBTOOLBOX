function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the handle to the main program
    mainGUI = gui.parent;

    % Create window
    figName = 'Extrapolate';
    if isa(mainGUI,'nb_GUI')
        name = [mainGUI.guiName ': ' figName];
    else
        name = figName;
    end
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    figureHandle = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65,   15,  100,   30],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'normal');
    gui.figureHandle = figureHandle;
    nb_moveFigureToMonitor(figureHandle,currentMonitor,'center');
    
    pointSize = nb_unitsRatio('points', 'normalized', figureHandle);
    marginX = 10 * pointSize(1);
    marginY = 10 * pointSize(2);
    rowHeight = 25 * pointSize(2);
    
    labelProps      = nb_constant.LABEL;   
    editProps       = nb_constant.EDIT; 
    popupProps      = nb_constant.POPUP;
    listboxProps    = nb_constant.LISTBOX;
    checkboxProps   = nb_constant.CHECKBOX;
    buttonProps     = nb_constant.BUTTON;
    radioProps      = nb_constant.RADIOBUTTON;
    
    mainGrid = nb_gridcontainer(figureHandle, ...
        'GridSize', [1, 2], ...
        'HorizontalWeight', [6 4], ...
        'Margin', 10);
    
    leftCol = nb_gridcontainer(mainGrid, ...
        'GridSize', [3, 1], ...
        'VerticalWeight', [3 6 1], ...
        'Margin', 10, ...
        'Padding', 0, ...
        'BorderWidth', 0);
    
    % COMMON OPTIONS
    commonGrid = nb_gridcontainer(leftCol, ...
        'GridSize', [3 2], ...
        'Margin', 10, ...
        'Padding', 0, ...
        'BorderWidth', 0);

    uicontrol(commonGrid, labelProps, 'String', 'Method:');
    components.method = uicontrol(commonGrid, popupProps, ...
        'Callback', @(varargin) gui.updateGUI());
    
    components.toDateString = uicontrol(commonGrid, labelProps, 'String', 'To date:');
    components.toDate = uicontrol(commonGrid, editProps);
    
    uicontrol(commonGrid, labelProps); % Blank
    dateTypeGroup = uibuttongroup(commonGrid, ...
        'BorderType', 'none', ...
        'SelectionChangeFcn', @(varargin) gui.updateGUI());
    uicontrol(dateTypeGroup, radioProps, ...
        'String', 'Date', ...
        'Position', [0 0 .5 1]);
    components.periodCheckBox = uicontrol(dateTypeGroup, radioProps, ...
        'String', 'Periods', ...
        'Position', [.5 0 .5 1]);
    
    % METHOD SPECIFIC OPTIONS
    methodGrid = nb_gridcontainer(leftCol, ...
        'title', 'Method options', ...
        'GridSize', [5 2], ...
        'Margin', 10);
    
    methodOptions.nLagsLabel = uicontrol(methodGrid, labelProps, 'String', 'Number of lags:');
    methodOptions.nLags = uicontrol(methodGrid, editProps, 'String', 5);
    
    methodOptions.drawsLabel = uicontrol(methodGrid, labelProps, 'String', 'Draws:');
    methodOptions.draws = uicontrol(methodGrid, editProps, 'String', 1000);
    
    methodOptions.checkLabel = uicontrol(methodGrid, labelProps, 'String', 'Check stationarity:'); 
    methodOptions.check = uicontrol(methodGrid, checkboxProps, ...
        'Callback', @(varargin) gui.updateGUI()); 
    
    methodOptions.alphaLabel = uicontrol(methodGrid, labelProps, 'String', 'Alpha:');
    methodOptions.alpha = uicontrol(methodGrid, editProps, 'String', 0.05);
    
    methodOptions.constantLabel = uicontrol(methodGrid, labelProps, 'String', 'Include constant:');
    methodOptions.constant = uicontrol(methodGrid, checkboxProps);
    
    components.methodOptions = methodOptions;
    
    % OK button
    uicontrol(leftCol, buttonProps, ...
        'String', 'Extrapolate', ...
        'Callback', @gui.extrapolateCallback);
    
    % Variable selection
    components.variables = uicontrol(mainGrid, listboxProps);
    
    gui.components = components;
    gui.updateGUI();
    set(figureHandle, 'Visible', 'on');

end
