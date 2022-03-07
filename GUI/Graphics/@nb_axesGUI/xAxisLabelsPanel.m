function xAxisLabelsPanel(gui)
% Syntax:
%
% xAxisLabelsPanel(gui)
%
% Description:
%
% Part of DAG. Creates the panel with the x-axis labels properties
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get graph object 
    plotter = gui.plotter;
    
    % Create panel
    %--------------------------------------------------------------
    uip = uipanel(gui.buttonPanel,...
        'button',              'X-Axis Labels',...
        'title',               '',...
        'borderType',          'none'); 
    gui.panelHandle5 = uip;
    
    % Manually set the x-tick labels
    %--------------------------------------------------------------
    if ~strcmpi(plotter.plotType,'scatter') && ~strcmpi(plotter.plotType,'pie')
    
        % Get all the types plotted
        old = plotter.xTickLabels(1:2:end);
        new = plotter.xTickLabels(2:2:end);
        
        % Create table with types options
        %--------------------------------------------------------------
        if isempty(old)
            tableData  = {'',''};
        else
            tableData  = [old',new']; 
        end
        
        colNames   = {'Old','New'};
        colEdit    = [true,true];
        colForm    = {'char','char'};
        gui.table2 = nb_uitable(uip,...
                        'units',                'normalized',...
                        'position',             [0.04, 0.04, 0.92, 0.92],...
                        'data',                 tableData,...
                        'columnName',           colNames,...
                        'columnFormat',         colForm,...
                        'columnEdit',           colEdit,...
                        'cellEditCallback',     @gui.xTickLabelsEdit,...
                        'cellSelectionCallback',@gui.getSelectedCells);
                    
        % Add context menu to table
        cMenu = uicontextmenu('parent',gui.figureHandle);
            uimenu(cMenu,'Label','Add','Callback',@gui.addRow);
            uimenu(cMenu,'Label','Delete','Callback',@gui.deleteRow);
        set(gui.table2,'UIContextMenu',cMenu);
              
    end
    
end
