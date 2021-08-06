function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Make the distribution GUI window.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Figure
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0, 'defaultUicontrolBackgroundColor');
    fig = nb_figure(...
        'visible',        'off',...
        'units',          'characters',...
        'position',       [40   15  160   50],...
        'Color',          defaultBackground,...
        'name',           'Select distribution',...
        'numberTitle',    'off',...
        'menuBar',        'None',...
        'toolBar',        'None',...
        'resize',         gui.resizeFigure);
    addlistener(fig, 'resized', @(src, event) resize(gui));
    gui.nbFigureHandle = fig;
    gui.figureHandle   = fig.figureHandle;
    nb_moveFigureToMonitor(gui.figureHandle, currentMonitor, 'center');
    
    addlistener(fig, 'mouseMove', @gui.mouseMoveCallback);
    addlistener(fig, 'mouseDown', @gui.mouseDownCallback);
    
    % Menu Bar
    addMenuBar(gui);  
    
    % Panels
    gui.graphPanel        = graphPanel(gui);
    gui.momentsPanel      = momentsPanel(gui);
    gui.distributionPanel = distributionPanel(gui);
    gui.domainPanel       = domainPanel(gui);
    gui.buttonPanel       = buttonPanel(gui);
    
    % Update state
    gui.updateGUI();
    
    % Make GUI visible
    set(gui.figureHandle,'visible','on');
end

function addMenuBar(gui)

    % Edit
    editMenu = uimenu(gui.figureHandle, 'Label', 'Edit');
    gui.makeHistoryGUI(editMenu, @gui.updateGUI);
    
    % PDF / CDF
    funcTypeMenu = uimenu(gui.figureHandle, 'Label', 'PDF / CDF');
    gui.pdfMenuItem = uimenu(funcTypeMenu, 'Label', 'PDF', 'Callback', @(varargin) gui.set('functionType', 'pdf'));
    gui.cdfMenuItem = uimenu(funcTypeMenu, 'Label', 'CDF', 'Callback', @(varargin) gui.set('functionType', 'cdf'));
    
    % Increment mode
    incrementMenu = uimenu(gui.figureHandle, 'Label', 'Increment mode');
    gui.incrementEnableMenuItem = uimenu(incrementMenu, 'Label', 'Enable', 'Callback', @gui.incrementEnableCallback);
    smoothingMenu = uimenu(incrementMenu, 'Label', 'Smoothing');
    gui.kernelSmoothingMenuItem = uimenu(smoothingMenu, 'Label', 'Kernel', 'Callback', @(varargin) gui.set('incrementSmoothing', 'kernel'));
    gui.neighbourhoodSmoothingMenuItem = uimenu(smoothingMenu, 'Label', 'Neighbourhood size...', 'Callback', @gui.neighbourhoodSmoothingCallback);
    gui.smoothingMenuItem = uimenu(gui.figureHandle, 'Label', 'Smoothing');
    uimenu(gui.smoothingMenuItem, 'Label', 'Kernel...', 'Callback', @gui.smoothingCallback);
    
    % Other
    otherMenu = uimenu(gui.figureHandle, 'Label', 'Other');
    uimenu(otherMenu, 'Label', 'Parametrize...', 'Callback', @gui.parametrizeCallback);
    uimenu(otherMenu, 'Label', 'Get percentiles...', 'Callback', @(varargin) gui.getPercentiles());
    if numel(gui.distribution) > 1
        uimenu(otherMenu, 'Label', 'Get mean from...', 'Callback', @(varargin) gui.getMeanFromCallback);
        uimenu(otherMenu, 'Label', 'Get mode from...', 'Callback', @(varargin) gui.getModeFromCallback);
    end

end

function panel = momentsPanel(gui)
    panel = nb_gridcontainer(gui.figureHandle, ...
        'Title', 'Moments', ...
        'Position', [0 .5 1 .5], ...
        'Margin', 10, ...
        'GridSize', [7, 2],...
        'BorderWidth',1);
    
    labelProps = nb_constant.LABEL;
    editProps = nb_constant.EDIT;
    editProps.Callback = @(varargin) gui.updateMomentsPanel();
    
    % Mean
    uicontrol(panel, labelProps, 'String', 'Mean');
    gui.meanText = uicontrol(panel, editProps);
    
    % Median
    uicontrol(panel, labelProps, 'String', 'Median');
    gui.medianText = uicontrol(panel, editProps);
    
    % Mode
    uicontrol(panel, labelProps, 'String', 'Mode');
    gui.modeText = uicontrol(panel, editProps);
    
    % Variance
    uicontrol(panel, labelProps, 'String', 'Variance');
    gui.varianceText = uicontrol(panel, editProps);
    
    % Std
    uicontrol(panel, labelProps, 'String', 'Std');
    gui.stdText = uicontrol(panel, editProps);

    % Skewness
    uicontrol(panel, labelProps, 'String', 'Skewness');
    gui.skewnessText = uicontrol(panel, editProps);
    
    % Kurtosis
    uicontrol(panel, labelProps, 'String', 'Kurtosis');
    gui.kurtosisText = uicontrol(panel, editProps);
end

function panel = graphPanel(gui)
    panel = uipanel(gui.figureHandle, 'BorderWidth', 0);
    
    gui.plotter = plot(gui.distribution);
    gui.plotter.set('legLocation','east');
    gui.plotter.setSpecial('figureHandle', panel);
    addContextMenu(gui.plotter);  
end

function addContextMenu(obj)

    menu = uicontextmenu();
    dataMenu = uimenu(menu,'Label','Data');
        uimenu(dataMenu,'Label','Spreadsheet','Callback',@obj.spreadsheetGUI);
    propertiesMenu = uimenu(menu,'Label','Properties');
        uimenu(propertiesMenu,'Label','Plot type','Callback',@obj.selectPlotTypeGUI);
        uimenu(propertiesMenu,'Label','Select variable','tag','changeWhenDatesVsDates','Callback',@obj.selectVariableGUI);
        uimenu(propertiesMenu,'Label','Legend','Callback',@obj.legendGUI);
        uimenu(propertiesMenu,'Label','Title','tag','title','Callback',@obj.addAxesTextGUI);
        uimenu(propertiesMenu,'Label','X-Axis Label','tag','xlabel','Callback',@obj.addAxesTextGUI);
        yLab = uimenu(propertiesMenu,'Label','Y-Axis Label','Callback','');
            uimenu(yLab,'Label','Left','tag','yLabel','Callback',@obj.addAxesTextGUI);
            uimenu(yLab,'Label','Right','tag','yLabelRight','Callback',@obj.addAxesTextGUI);
        uimenu(propertiesMenu,'Label','Axes','Callback',@obj.axesPropertiesGUI); 
        uimenu(propertiesMenu,'Label','Look Up','Callback',@obj.lookUpGUI);  
        uimenu(propertiesMenu,'Label','General','Callback',@obj.generalPropertiesGUI); 
    annotationMenu = uimenu(menu,'Label','Annotation');
                uimenu(annotationMenu,'Label','Horizontal Line','tag','removeWhenRadarPie','Callback',{@obj.lineGUI,'horizontal'});
                uimenu(annotationMenu,'Label','Vertical Line','tag','removeWhenRadarPie2','Callback',{@obj.lineGUI,'vertical'});
                uimenu(annotationMenu,'Label','Highlighted Area','tag','removeWhenRadarPie2','Callback',@obj.highlightGUI);
                uimenu(annotationMenu,'Label','Text Box','separator','on','Callback',@obj.addTextBox);
                uimenu(annotationMenu,'Label','Rectangle','Callback',@obj.addDrawPatch);
                uimenu(annotationMenu,'Label','Circle','Callback',@obj.addDrawPatch);
                uimenu(annotationMenu,'Label','Arrow','Callback',@obj.addArrow);
                uimenu(annotationMenu,'Label','Text Arrow','Callback',@obj.addTextArrow);
                uimenu(annotationMenu,'Label','Curly Brace','Callback',@obj.addCurlyBrace);
                bar = uimenu(annotationMenu,'Label','Bar Annotation','separator','on');
                    uimenu(bar,'Label','Add','callback',@obj.addBarAnnotation);
                    uimenu(bar,'Label','Edit...','callback',@obj.editBarAnnotation);
                    uimenu(bar,'Label','Delete','callback',@obj.deleteBarAnnotation);  
    obj.setSpecial('UIContextMenu', menu);
                    
end

function panel = distributionPanel(gui)
    panel = nb_gridcontainer(gui.figureHandle,...
        'Title',        'Distribution', ...
        'Margin',       10,...
        'GridSize',     [3, 4],...
        'BorderWidth',  1);
    
    labelProps = nb_constant.LABEL;
    editProps  = nb_constant.EDIT;
    popupProps = nb_constant.POPUP;
    param      = cell(1,5);
    paramB     = cell(1,5);
    
    % Distribution type
    uicontrol(panel, labelProps, 'String', 'Distribution');
    gui.distributionMenu = uicontrol(panel, popupProps, ...
        'string', gui.distributions,...
        'callback', @gui.distributionMenuCallback);
    
    % Third parameter
    param{3}  = uicontrol(panel, labelProps);
    paramB{3} = uicontrol(panel, editProps, ...
        'callback', @gui.paramBoxCallback); 
    
    % First parameter
    param{1}  = uicontrol(panel, labelProps);
    paramB{1} = uicontrol(panel, editProps, ...
        'callback', @gui.paramBoxCallback);  
        
    % Fourth parameter
    param{4}  = uicontrol(panel, labelProps);
    paramB{4} = uicontrol(panel, editProps, ...
        'callback', @gui.paramBoxCallback); 
    
    % Second parameter
    param{2}  = uicontrol(panel, labelProps);
    paramB{2} = uicontrol(panel, editProps, ...
        'callback', @gui.paramBoxCallback); 
    
    % Fifth parameter
    param{5}  = uicontrol(panel, labelProps);
    paramB{5} = uicontrol(panel, editProps, ...
        'callback', @gui.paramBoxCallback); 
    
    gui.paramLabels = param;
    gui.paramBoxes  = paramB;
    
    % Percentiles (only for kernel distribution)
    gui.percentileLabel = uicontrol(panel, labelProps, ...
        'String', 'Percentiles', ...
        'Visible', 'off');
    gui.percentileButton = uicontrol(panel, nb_constant.BUTTON, ...
        'string', 'Edit...',...
        'Visible', 'off', ...
        'callback', @(src, evt) gui.setPercentiles());
end

function panel = domainPanel(gui)
    panel = nb_gridcontainer(gui.figureHandle, ...
        'Title', 'Domain', ...
        'Margin', 10, ...
        'GridSize', [7, 2],...
        'BorderWidth',1);
    
    labelProps = nb_constant.LABEL;
    editProps = nb_constant.EDIT;
    editProps.Callback = @gui.domainCallback;
    
    % Domain: Lower
    uicontrol(panel, labelProps, 'String', 'Lower bound');
    gui.domainLowerBox = uicontrol(panel, editProps); 
          
    % Domain: Upper
    uicontrol(panel, labelProps, 'String', 'Upper bound');
    gui.domainUpperBox = uicontrol(panel, editProps);
    
    % Mean Shift
    uicontrol(panel, labelProps, 'String', 'Mean shift');
    gui.meanShiftBox = uicontrol(panel, editProps);
end

function panel = buttonPanel(gui)
    panel = nb_gridcontainer(gui.figureHandle, ...
        'Margin', 10, ...
        'GridSize', [3, 1], ...
        'BorderWidth', 0);
    
    % Distribution object
    gui.currentDistributionMenu = uicontrol(panel, nb_constant.POPUP, ...
        'string', {gui.distribution.name},...
        'callback', @gui.currentDistributionMenuCallback);
    
    % Done
    uicontrol(panel, nb_constant.BUTTON, ...
        'string', 'Done',...
        'callback', @gui.okButtonCallback);
end
