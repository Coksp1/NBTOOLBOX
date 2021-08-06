function colorMapPanel(gui)
% Syntax:
%
% colorMapPanel(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get graph object 
    plotter = gui.plotter;
    
    % Add grid panel
    grid = nb_gridcontainer(gui.buttonPanel,...
        'button',    'Color Map',...
        'GridSize',  [20, 3],...
        'position',  [0.03,0,0.95,0.96],...
        'HorizontalWeight',[0.28,0.47,0.25]);
    
    % Color map
    uicontrol(grid,nb_constant.LABEL,'string','Color Map');

    mapping = plotter.colorMap;
    if ~ischar(mapping)
        mapping = '';
    end
    gui.colorMapEdit = uicontrol(grid,nb_constant.EDIT,...
              'string',    mapping,...
              'callback',  {@gui.set,'colorMap'}); 
    uicontrol(grid,nb_constant.BUTTON,...
              'string',    'Select file...',...
              'callback',  @gui.loadFileCallback);  
          
end
