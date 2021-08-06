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

    plotter = gui.plotter;
    if ~plotter.DB.isUpdateable
        nb_errorWindow('The data of the graph is not updateable. No link to the data source.')
       return 
    end
    
    % GUI window
    %--------------------------------------------------------------
    gui.figureHandle = nb_guiFigure(plotter.parent,'Stop update',[65   15  50   8],'modal','off',@gui.closeCallback);  
    panel            = nb_gridcontainer(gui.figureHandle, ...
        'Title',       '', ...
        'Units',       'normalized',...
        'position',	   [0.04, 0.04, 0.96, 0.96], ...
        'BorderWidth', 0, ...
        'GridSize',    [3 2], ...
        'Margin',      10);
    
    % stopUpdate
    %--------------------------------------------------------------
    uicontrol(panel,nb_constant.LABEL,'string', 'Stop update');

    plotter.setSpecial('returnLocal',true);      
    string = plotter.stopUpdate;
    plotter.setSpecial('returnLocal',false);
    
    gui.comp.stopUpdate = uicontrol(panel,nb_constant.EDIT,'string',string,'callback',@gui.setCallback); 
     
    nb_emptyCell(panel);
    
    uicontrol(panel,nb_constant.LABEL,'string', 'Format: yyyymmddhh');
    
    nb_emptyCell(panel);
    
    uicontrol(panel,nb_constant.LABEL,'string', 'or yyyymmddhhmm');
    
    % Make visible
    %--------------------------------------------------------------
    set(gui.figureHandle,'visible','on');
          
end
