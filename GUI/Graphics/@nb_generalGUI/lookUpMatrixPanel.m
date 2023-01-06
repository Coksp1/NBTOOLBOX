function lookUpMatrixPanel(gui)
% Syntax:
%
% lookUpMatrixPanel(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get graph object 
    plotterT = gui.plotter;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'off',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle5 = uip;
    
    % Create table with look up matrix
    %--------------------------------------------------------------
    tableData = plotterT.lookUpMatrix;
    if isempty(tableData)
        tableData            = {'','',''};
        plotterT.lookUpMatrix = {'','',''};
    else
        tableData(:,2) = nb_multilined2line(tableData(:,2),' \\ ');
        tableData(:,3) = nb_multilined2line(tableData(:,3),' \\ ');
    end
    
    if size(tableData,2) ~= 3
        nb_infoWindow(['The look up matrix of the graph object has not the correct size. '...
                        'Must have 3 columns, has ' int2str(size(plotterT.lookUpMatrix,2)) '.'],'Look up Matrix')
        tableData            = {'','',''};            
        plotterT.lookUpMatrix = {};           
    end
    
    colNames  = {'Looked up','English','Norwegian'};
    colEdit   = true(1,3);
    colForm   = cell(1,3);
    colForm(:)= {'char'};
    t = nb_uitable(...
            uip,...
            'units',                'normalized',...
            'position',             [0 0 1 1],...
            'data',                 tableData,...
            'columnName',           colNames,...
            'columnFormat',         colForm,...
            'columnEdit',           colEdit,...
            'cellEditCallback',     @gui.cellEdit,...
            'cellSelectionCallback',@gui.getSelectedCells);

    gui.table = t;

    % Add context menu to table
    %--------------------------------------------------------------
    cMenu = uicontextmenu('parent',gui.figureHandle);
        uimenu(cMenu,'Label','Add','Callback',@gui.addRow);
        uimenu(cMenu,'Label','Delete','Callback',@gui.deleteRow);
    set(t,'UIContextMenu',cMenu);

end
