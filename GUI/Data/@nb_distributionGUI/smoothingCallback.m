function smoothingCallback(gui, varargin)
% Syntax:
%
% smoothingCallback(gui, varargin)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Figure
    currentMonitor    = nb_getCurrentMonitor();
    fig = figure(...
        'visible', 'off', ...
        'units',          'characters',...
        'position',       [0 0 40 10],...
        'Color',          get(0, 'defaultUicontrolBackgroundColor'),...
        'name',           'Kernel smoothing',...
        'numberTitle',    'off',...
        'menuBar',        'None',...
        'toolBar',        'None',...
        'resize',         'off');
    nb_moveFigureToMonitor(fig, currentMonitor, 'center');
    
    labelParams = nb_constant.LABEL; 
    editParams = nb_constant.EDIT;
    
    container = nb_gridcontainer(fig, ...
        'GridSize', [2, 1], ...
        'VerticalWeight', [2 1], ...
        'Margin', 10, ...
        'BorderWidth', 0);
    
    optionGrid = nb_gridcontainer(container, ...
        'GridSize', [2 2], ...
        'Margin', 10, ...
        'Padding', 0);
    
    % Lower bound
    uicontrol(optionGrid, labelParams, 'String', 'Lower bound');
    lowText = uicontrol(optionGrid, editParams);
    
    % Upper bound
    uicontrol(optionGrid, labelParams, 'String', 'Upper bound');
    uppText = uicontrol(optionGrid, editParams);
    
    uicontrol(container, nb_constant.BUTTON, ...
        'string', 'OK',...
        'callback', @callback);
    
    set(fig, 'Visible', 'on');

    function callback(varargin)
        
        low = get(lowText, 'string');
        if isempty(low)
            low = -inf;
        else
            low = str2double(low);
        end
        if isnan(low)
            nb_errorWindow('Lower bound must be a number')
            return
        end
        
        upp = get(uppText, 'string');
        if isempty(upp)
            upp = inf;
        else
            upp = str2double(upp);
        end
        if isnan(upp)
            nb_errorWindow('Upper bound must be a number')
            return
        end
        
        if low > upp
            nb_errorWindow('Upper bound must be a lower number than lower bound')
            return
        end
        
        if ~strcmpi(gui.currentDistribution.type,'kernel')
            gui.currentDistribution = convert(gui.currentDistribution);
        end
    
        try
            smoothDensity(gui.currentDistribution,'kernel','support',[low,upp]);
        catch Err
            nb_errorWindow(Err.message,Err);
        end

        gui.addToHistory();
        gui.updateGUI();
        
        delete(fig);
    end

end
