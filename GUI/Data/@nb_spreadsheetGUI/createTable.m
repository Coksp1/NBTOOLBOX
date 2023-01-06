function createTable(gui)
% Syntax:
%
% createTable(gui)
%
% Description:
%
% Part of DAG. Create the table
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the column width
    switch lower(gui.tableType)

        case 'freeze'

            rows = 1;
            cols = 1;

            % Get the editability
            colEdit = false(1,cols);

            % Row names
            rowNames = nb_spreadsheetGUI.createDefaultFirstColumn(rows);

            % Column names
            colNames = nb_spreadsheetGUI.createDefaultFirstRow(cols);

            % Get the column format
            colForm    = cell(1,cols);
            colForm(:) = {'numeric'};

            % Data
            dataNaN = nan(rows,cols);

            % Create default table
            gui.table = nb_uitable(gui.figureHandle,...
                    'units',                'normalized',...
                    'position',             [0 0.05 1 0.95],...
                    'data',                 dataNaN,...
                    'columnName',           colNames,...
                    'columnFormat',         colForm,...
                    'columnEdit',           colEdit,...
                    'rowName',              rowNames,...
                    'cellSelectionCallback',@gui.getSelectedCells);

        case 'unfreeze'

            rows = 50;
            cols = 25;

            % Get the editability
            colEdit = false(1,cols);

            % Row names
            rowNames = nb_spreadsheetGUI.createDefaultFirstColumn(rows);

            % Column names
            colNames = nb_spreadsheetGUI.createDefaultFirstRow(cols);

            % Get the column format
            colForm    = cell(1,cols);
            colForm(:) = {'char'};

            % Empty data
            dataT = cell(rows,cols);

            % Create default table
            gui.table = nb_uitable(gui.figureHandle,...
                    'units',                'normalized',...
                    'position',             [0 0 1 1],...
                    'data',                 dataT,...
                    'columnName',           colNames,...
                    'columnFormat',         colForm,...
                    'columnEdit',           colEdit,...
                    'rowName',              rowNames,...
                    'cellSelectionCallback',@gui.getSelectedCells);

    end

    % Context menu
    addContextMenu(gui);   

end
