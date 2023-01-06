function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Creates the menu for changing a variable's properties.
% When graph is open: Properties > Select Variable.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;
    parent  = gui.plotter.parent;
    name    = 'Select Variable';

    % Create the main window
    %--------------------------------------------------------------
    f = nb_guiFigure(parent,name,[40   15  85.5   31.5],'modal','off');
    gui.figureHandle = f;
    
    % Find the coordinate parameters
    %--------------------------------------------------------------
    popWidth1 = 0.41;
    popHeight = 0.05;
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;

    if isa(plotter,'nb_graph_ts')
        if isempty(plotter.datesToPlot)
            string = 'Select Variable';
            list   = plotter.DB.variables;
        else
            string = 'Select Date';
            list   = nb_getDatesAndLocals(plotter.DB);
        end
    else
        string = 'Select Variable';
        list   = plotter.DB.variables;
    end
    
    % Select variable pop-up menu
    %------------------------------------------------------
    uicontrol('units',                  'normalized',...
              'position',               [startX, startY + popHeight, popWidth1, tHeight],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 string); 

    pop1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startX, startY, popWidth1, popHeight],...
              'parent',         f,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         list,...
              'callback',       @gui.changeVariable); 

    gui.figureHandle = f;
    gui.popupmenu1   = pop1;   

    % Create the rest of the GUI
    updateGUI(gui,list{1},1);

    % Make the GUI visible.
    %------------------------------------------------------
    set(f,'Visible','on');

end
