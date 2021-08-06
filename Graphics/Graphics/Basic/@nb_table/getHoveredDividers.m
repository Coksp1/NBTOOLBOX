function [rowDivider, columnDivider] = getHoveredDividers(obj)
    tolerance = 0.01;

    rowDividers    = [0 cumsum(fliplr(obj.RowSizes))];
    columnDividers = [0 cumsum(obj.ColumnSizes)];

    [~, mousePos] = nb_getCurrentPointInAxesUnits(obj.parent.parent, obj.parent);
    if any(mousePos<0) || any(mousePos>1)
        columnDivider = [];
        rowDivider    = [];
    else
        columnDivider = find(abs(mousePos(1) - columnDividers) < tolerance, 1);
        rowDivider    = find(abs(mousePos(2) - rowDividers) < tolerance, 1);
    end
    
    % Ignore outer edges
    % rowDivider(rowDivider == 1 | rowDivider == length(rowDividers)) = [];
    % columnDivider(columnDivider == 1 | columnDivider == length(columnDividers)) = [];
end
