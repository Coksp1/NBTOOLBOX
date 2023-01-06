 function neighbourhoodSmoothingCallback(gui, varargin)   
 % Syntax:
%
% neighbourhoodSmoothingCallback(gui, varargin)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Figure
    currentMonitor    = nb_getCurrentMonitor();
    fig = figure(...
        'visible', 'off', ...
        'units',          'characters',...
        'position',       [0 0 40 7],...
        'Color',          get(0, 'defaultUicontrolBackgroundColor'),...
        'name',           'Smoothing',...
        'numberTitle',    'off',...
        'menuBar',        'None',...
        'toolBar',        'None',...
        'resize',         'off');
    nb_moveFigureToMonitor(fig, currentMonitor, 'center');
    
    labelProps = nb_constant.LABEL;   
    editProps = nb_constant.EDIT;
    
    grid = nb_gridcontainer(fig, ...
        'Margin', 10, ...
        'GridSize', [2, 1], ...
        'BorderWidth', 0);
    
    % Neighbourhood size
    size = nb_conditional(...
        nb_iswholenumber(gui.incrementSmoothing), ...
        gui.incrementSmoothing, 1);
    
    row = nb_gridcontainer(grid, 'GridSize', [1 2], 'Padding', 0, 'BorderWidth', 0);
    uicontrol(row, labelProps, 'String', 'Neighbourhood size');
    sizeText = uicontrol(row, editProps, 'String', size);
    
    uicontrol(grid, nb_constant.BUTTON, ...
        'string', 'Done',...
        'callback', @callback);
    
    set(fig, 'Visible', 'on');

    function callback(varargin)
        gui.incrementSmoothing = str2double(get(sizeText, 'string'));
        gui.updateGUI();
        delete(fig);
    end

end
