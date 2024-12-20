function locationPanel(gui)
% Creates a panel for editing general legend properties  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get graph object 
    obj = gui.parent;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'on',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle1 = uip;
    

    % Coordinates
    %--------------------------------------------------------------
    gui.table = nb_uitable(...
                'parent',                uip,...
                'position',              [0,0,1,1],...
                'units',                 'normalized',...
                'data',                  [obj.xData,obj.yData],...
                'columnName',            {'x','y'},...
                'columnEdit',            true(1,2),...
                'cellEditCallback',      @gui.cellEdit,...
                'cellSelectionCallback', @gui.getSelectedCells);
    
    % Add context menu to table
    %--------------------------------------------------------------
    cMenu = uicontextmenu('parent',gui.figureHandle);
        uimenu(cMenu,'Label','Add','Callback',@gui.addRow);
        uimenu(cMenu,'Label','Delete','Callback',@gui.deleteRow);
    set(gui.table,'UIContextMenu',cMenu);
           
end
