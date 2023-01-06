function grid = test()
% Syntax:
%
% grid = nb_gridcontainer.test()
%
% Description:
%
% Test the class.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    parent = figure();
    grid = nb_gridcontainer(parent, ...
        'Units', 'Normalized', ...
        'Position', [.2, .2, .6, .6], ...
        'GridSize', [3 2], ...
        'HorizontalWeight', [2 1], ...
        'VerticalWeight', [5 5 2], ...
        'Margin', 10);
    uicontrol(grid, nb_constant.LABEL, 'String', '1');
    uicontrol(grid, nb_constant.POPUP, 'String', {'2'});

    % Invisible controls should not take up place
    thirdChild = uicontrol(grid, nb_constant.BUTTON, 'String', '3', 'Visible', 'off');

    % Button group
    group = uibuttongroup(grid, 'BorderType', 'none');
    uicontrol(group, nb_constant.RADIOBUTTON, 'String', '4a', 'Position', [0 0 .5 1]);
    uicontrol(group, nb_constant.RADIOBUTTON, 'String', '4b', 'Position', [.5 0 .5 1]);

    % Nested nb_gridcontainer
    nestedGrid = nb_gridcontainer(grid, 'GridSize', [1 2], 'Padding', 0, 'BorderWidth', 0);
    uicontrol(nestedGrid, nb_constant.LABEL, 'String', 'Nested 1');
    uicontrol(nestedGrid, nb_constant.LABEL, 'String', 'Nested 2');

    % Toggle visibility of inner child
    set(thirdChild, 'Visible', 'on');
    grid.update();
end
