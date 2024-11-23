function addColumn(obj, x)
% Adds column at position x,
% copying formatting from the preceding column

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    oldSize = obj.size;

    % Move succeeding columns
    obj.cells(:, x+1:end+1) = obj.cells(:, x:end);
    
    % Copy formatting from neighbouring column
    if (x == 1)
        obj.cells(:, x) = obj.cells(:, x + 1);
    else
        obj.cells(:, x) = obj.cells(:, x - 1);
    end
    
    % Clear string and create graphic objects
    for y = 1:obj.size(1)
        obj.cells(y, x).String = {''};
        obj.cells(y, x).graphicHandles = obj.createCellGraphics(); 
    end

    % Recalculate column sizes
    obj.ColumnSizes(x+1:end+1) = obj.ColumnSizes(x:end);
    obj.ColumnSizes(x) = 1 / oldSize(2);
    obj.ColumnSizes = obj.ColumnSizes / sum(obj.ColumnSizes);

    obj.update();
    
end
