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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;

    % Create the main window
    name             = 'Remove Observations';
    gui.figureHandle = nb_guiFigure(parent,name,[40   15  85.5   31.5],'modal');  
    
    % Positions
    popWidth1 = 0.41;
    popHeight = 0.05;
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;

    % Select line object pop-up menu
    uicontrol(nb_constant.LABEL,...
              'position',[startX, startY + popHeight, popWidth1, tHeight],...
              'parent',  gui.figureHandle,....
              'string',  'Select Variable'); 

    pop1 = uicontrol(nb_constant.POPUP,...
              'position', [startX, startY, popWidth1, popHeight],...
              'parent',   gui.figureHandle,...
              'string',   plotterT.DB.variables,...
              'value',    1,...
              'tag',      'left',...
              'callback', @gui.changeVariable); 
    gui.varpopup = pop1;
            
    % Create the rest of the panel (Highlight options)
    updatePanel(gui,plotterT.DB.variables{1});

    % Make GUI visible 
    set(gui.figureHandle,'visible','on');
          
end
