function parametrizeCallback(gui, varargin)
% Syntax:
%
% parametrizeCallback(gui, varargin)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.currentDistribution.type,'kernel')
        nb_errorWindow('Parametrization is not supported for a distribution of type kernel')
        return
    end

    % Figure
    currentMonitor = nb_getCurrentMonitor();
    fig = figure(...
        'visible', 'off', ...
        'units',          'characters',...
        'position',       [0 0 40 10],...
        'Color',          get(0, 'defaultUicontrolBackgroundColor'),...
        'name',           'Parametrize',...
        'numberTitle',    'off',...
        'menuBar',        'None',...
        'toolBar',        'None',...
        'resize',         'off');
    nb_moveFigureToMonitor(fig, currentMonitor, 'center');
    
    labelParams = nb_constant.LABEL;
    editParams = nb_constant.EDIT;
    
    grid = nb_gridcontainer(fig, ...
        'Margin', 10, ...
        'GridSize', [2, 1], ...
        'VerticalWeight', [2 1]);   
    
    optionGrid = nb_gridcontainer(grid, ...
        'GridSize', [2 2], ...
        'Margin', 10, ...
        'Padding', 0, ...
        'BorderWidth', 0);
    
    % Mean
    uicontrol(optionGrid, labelParams, 'String', 'Mean');
    meanText = uicontrol(optionGrid, editParams);
    
    % Variance
    uicontrol(optionGrid, labelParams, 'String', 'Variance');
    varianceText = uicontrol(optionGrid, editParams);
    
    uicontrol(grid, nb_constant.BUTTON, ...
        'string',             'Parametrize',...
        'callback',           @callback);
    
    set(fig, 'Visible', 'on');

    function callback(varargin)
        
        mean = str2double(get(meanText, 'string'));
        if isnan(mean)
            nb_errorWindow('Mean must be a number')
            return
        end
        
        variance = str2double(get(varianceText, 'string'));
        if isnan(variance)
            nb_errorWindow('Variance must be a number')
            return
        end
        
        type     = get(gui.currentDistribution, 'type');

        lowerBoundStr = get(gui.domainLowerBox, 'string');
        if isempty(lowerBoundStr)
            lowerBound = [];
        else
            lowerBound = str2double(lowerBoundStr);
        end

        upperBoundStr = get(gui.domainUpperBox, 'string');
        if isempty(upperBoundStr)
            upperBound = [];
        else
            upperBound = str2double(upperBoundStr);
        end

        meanShiftStr = get(gui.meanShiftBox, 'string');
        if ~isempty(meanShiftStr)
            meanShift = str2double(meanShiftStr);
            mean      = mean - meanShift;
        end

        try
            [~, params] = nb_distribution.parametrization(mean, variance, type, lowerBound, upperBound);
            set(gui.currentDistribution, 'parameters', params);
        catch Err
            nb_errorWindow(Err.message,Err);
        end

        gui.addToHistory();
        gui.updateGUI();
        
        delete(fig);
    end

end
