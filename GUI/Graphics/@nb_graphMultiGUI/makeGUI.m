function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG. Make GUI figure
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.parent)
        name = 'Graphics';
        set(0,'DefaultFigureWindowStyle','normal');
    else
        parent = nb_getParentRecursively(gui);
        name   = [parent.guiName ': Graphics'];
    end
    if ~isempty(gui.figureName)
        name = [name, ': ' gui.figureName];
    end

    % Create the main window
    %------------------------------------------------------
    currentMonitor = nb_getCurrentMonitor();
    f    = nb_graphPanel('[4,3]',...
                         'visible',        'off',...
                         'units',          'characters',...
                         'position',       [40   15  186.4   43],...
                         'Color',          [1 1 1],...
                         'name',           name,...
                         'numberTitle',    'off',...
                         'dockControls',   'off',...
                         'menuBar',        'None',...
                         'toolBar',        'None',...
                         'tag',            'main');
    main = f.figureHandle;                 
    nb_moveFigureToMonitor(main,currentMonitor,'center');    

    % Assign object the handel to the window
    %------------------------------------------------------
    gui.figureHandle = f;
    updateGUI(gui)
    
    % Make the GUI visible.
    %------------------------------------------------------
    set(main,'Visible','on');
    
end
