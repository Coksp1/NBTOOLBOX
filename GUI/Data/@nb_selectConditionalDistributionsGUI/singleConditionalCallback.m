function singleConditionalCallback(gui,~,~)
% Syntax:
%
% singleConditionalCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    sel = gui.selectedCells;
    if isempty(sel)
        return 
    end

    d = gui.distributions(sel(:,1),sel(:,2));
    if numel(d) ~= 1
        nb_errorWindow('Cannot edit the hard conditional value of more than one distribution at.')
    end
    conditionalValue = num2str(d.conditionalValue);

    % Crate window
    %--------------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    fig = figure('visible',        'off',...
                 'units',          'characters',...
                 'position',       [45   10  50   7],...
                 'name',           'Hard condition',...
                 'numberTitle',    'off',...
                 'menuBar',        'None',...
                 'windowStyle',    'modal',...
                 'toolBar',        'None',...
                 'color',          defaultBackground);
    movegui(fig,'center');
    nb_moveFigureToMonitor(fig,currentMonitor);
    
    grid = nb_gridcontainer(fig, ...
        'Margin', 10, ...
        'GridSize', [2, 1], ...
        'BorderWidth', 0);
    
    % Value
    row1 = nb_gridcontainer(grid, 'GridSize', [1 2], 'BorderWidth', 0);
    uicontrol(row1, nb_constant.LABEL, 'String', 'Hard conditional value');
    cond = uicontrol(row1, nb_constant.EDIT, 'String', conditionalValue);
    
    uicontrol(grid, nb_constant.BUTTON, ...
        'string', 'Done',...
        'callback', @callback);
    
    set(fig, 'Visible', 'on');

    function callback(varargin)
        value = get(cond, 'string');
        if isempty(value) 
            d.conditionalValue = [];
        else
            value = str2double(value);
            if ~isnan(value)
                d.conditionalValue = value;
            else
                nb_errorWindow('The selected value is not a number')
            end           
        end
        gui.addToHistory();
        gui.updateGUI();
        delete(fig);
    end
    
end
