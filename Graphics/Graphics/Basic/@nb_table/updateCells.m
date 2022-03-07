function updateCells(obj, newSize)
% Update struct array width default table cells if expanded, or deleted if
% truncated. Will also update the RowSizes and ColumnSizes properties

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    oldSize = obj.size;
    diffSize = newSize - oldSize;
    
    cells = obj.cells;
    newRows = [];
    newColumns = [];

    if diffSize(1) > 0
        newRows = nb_table.defaultCells([diffSize(1) newSize(2)]);
    else
        cells = cells(1:newSize(1), :);
    end

    if diffSize(2) > 0
        newColumns = nb_table.defaultCells([newSize(1) diffSize(2)]);
    else
        cells = cells(:, 1:newSize(2));
    end

    % Remove possible duplicate cells
    if all(diffSize > 0)
        newColumns = newColumns(1:end - diffSize(1), :);
    end

    obj.cells = [cells, newColumns; newRows];
    updateSizes(obj);
end

function updateSizes(obj)
    oldSize = [length(obj.RowSizes), length(obj.ColumnSizes)];
    newSize = obj.size;
    overlap = min(oldSize, newSize);
    
    rowSizes = ones(1, newSize(1)) / oldSize(1);
    rowSizes(1:overlap(1)) = obj.RowSizes(1:overlap(1));
    rowSizes = rowSizes / sum(rowSizes);
    
    columnSizes = ones(1, newSize(2)) / oldSize(2);
    columnSizes(1:overlap(2)) = obj.ColumnSizes(1:overlap(2));
    columnSizes = columnSizes / sum(columnSizes);
    
    obj.RowSizes = rowSizes;
    obj.ColumnSizes = columnSizes;
end
