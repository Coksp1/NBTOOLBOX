function textPanel(gui)
% Syntax:
%
% textPanel(gui)
%
% Description:
%
% Part of DAG. Creates the text edit panel
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get all the info from the graph object
    plotterT          = gui.plotter;
    [allVars,legends] = interpretLegendText(plotterT);
    
    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle1 = uip;

    % Create table with legend options
    %--------------------------------------------------------------
    tableData = [allVars',legends'];
    if isempty(tableData)
        tableData = {'',''};
        enable    = 'off';
    else
        enable = 'on';
    end
    colNames  = {'Variables','Legends'};
    colEdit   = [false,true];
    colForm   = cell(1,2);
    colForm(:)= {'char'};
    gui.table = nb_uitable(uip,...
                    'units',                'normalized',...
                    'position',             [0 0 1 1],...
                    'data',                 tableData,...
                    'enable',               enable,...
                    'columnName',           colNames,...
                    'columnFormat',         colForm,...
                    'columnEdit',           colEdit,...
                    'cellEditCallback',     @gui.cellEdit);

end

%==========================================================================
% SUB
%==========================================================================
function [allVars,legends] = interpretLegendText(plotterT)

    legText  = plotterT.legendText;
    allVars  = getPlottedVariables(plotterT,true);
    
    if ~isempty(plotterT.fakeLegend)
        allVars = [allVars,plotterT.fakeLegend(1:2:end)];
    end
    
    if ~isempty(plotterT.patch)
        allVars = [plotterT.patch(1:4:end),allVars];
    end
    
    legends  = allVars;
    nVars    = length(allVars);
    for ii = 1:nVars
        
        ind = find(strcmp(allVars{ii},legText),1);
        try
            if ~isempty(ind)
                legends{ii} = legText{ind+1};
            end
        catch
            
        end
    end 
    legends  = nb_multilined2line(legends,' \\ ');
    
end
