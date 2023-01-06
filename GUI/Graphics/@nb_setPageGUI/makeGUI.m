function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Creates the pop-up menu for selecting page.
% With a graph open: Data > Page.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    parent = gui.plotter.parent;
    name   = 'Select Page'; 
    
    % Create the main window
    %--------------------------------------------------------------
    
    f = nb_guiFigure(parent,name,[65   15  60   9],'modal','off');
    gui.figureHandle = f;
   
    % Make the grid and add components
    %--------------------------------------------------------------
    g    = nb_gridcontainer(f,...
            'GridSize', [3 1],...
            'position', [0.04,0.1,0.92,0.8]);
    
    pages          = gui.plotter.DB.dataNames;     
    gui.popupmenu  = uicontrol(g,nb_constant.POPUP,...
                            'String',  pages,...
                            'position', [0.1,0.4,0.8,0.4]);
    nb_emptyCell(g);    
    g2    = nb_gridcontainer(g,'GridSize', [1 3]);                    
    nb_emptyCell(g2);                    
    nb_uicontrolDAG(parent,g2,nb_constant.BUTTON,...
               'string',   'Select',...
               'position', [0.1,0.1,0.1,0.1],...
               'callback', @gui.selectPageCallback,...
               'tooltip', 'Vas');

    % Make GUI visible
    %--------------------------------------------------------------
    set(f,'visible','on');

end
