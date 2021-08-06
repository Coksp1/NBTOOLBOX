function makeGUI(gui)    
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% Creates the look up matrix.
% With graph open: Properties > Look Up Matrix 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    parent = gui.plotter.parent;
    name   = 'Look Up Matrix';
    
    % Create the main window
    %------------------------------------------------------  
    f = nb_guiFigure(parent, name,[40   15  120   31.5],'modal','off'); 
    gui.figureHandle = f;
    
    % Create fixed panels
    %------------------------------------------------------
    background       = [1,1,1];
    fph              = nb_fixedPanel(f,2);
    fph.fixed(1)     = true;
    fph.weights      = [0.05,0.95];
    fph.minimum      = [nan,100];
    upper            = fph.children(2);
    lower            = fph.children(1);
    
    % Set colors of panels
    set(fph.children,'backgroundColor',background);
    
    % Create table with look up matrix
    %--------------------------------------------------------------
    plotterT  = gui.plotter;
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
            gui.figureHandle,...
            'parent',               upper,...
            'units',                'normalized',...
            'position',             [0 0 1 1],...
            'data',                 tableData,...
            'columnName',           colNames,...
            'columnFormat',         colForm,...
            'columnEdit',           colEdit,...
            'cellEditCallback',     @gui.cellEdit,...
            'cellSelectionCallback',@gui.getSelectedCells);

    gui.table = t;
    
    % Add help message
    %--------------------------------------------------------------
    nb_uicontrol(lower,nb_constant.LABEL,...
                        'position',        [0.02  0   1   1],...
                        'String',          'To introduce a line shift in the text, use \\ at the point where you want the line break.',...
                        'backGroundColor',  background);

    % Add context menu to table
    %--------------------------------------------------------------
    cMenu = uicontextmenu('parent',gui.figureHandle);
        uimenu(cMenu,'Label','Add','Callback',@gui.addRow);
        uimenu(cMenu,'Label','Delete','Callback',@gui.deleteRow);
        uimenu(cMenu,'Label','Add all variables','Callback',@gui.addAllVariables);
        uimenu(cMenu,'Label','Add all legends','Callback',@gui.addAllLegends);
    set(t,'UIContextMenu',cMenu);
    
    set(f,'visible','on')
    
end
