function addRow(obj, y)
% Adds row at position y,
% copying formatting from the preceding row

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    oldSize = obj.size;

    % Move succeeding rows
    obj.cells(y+1:end+1, :) = obj.cells(y:end, :);
    
    % Copy formatting from neighbouring row
    if (y == 1)
        obj.cells(y, :) = obj.cells(y + 1, :);
    else
        obj.cells(y, :) = obj.cells(y - 1, :);
    end
    
    % Clear string and create graphic objects
    for x = 1:obj.size(2)
        obj.cells(y, x).String = {''};
        obj.cells(y, x).graphicHandles = obj.createCellGraphics(); 
    end

    % Recalculate row sizes
    obj.RowSizes(y+1:end+1) = obj.RowSizes(y:end);
    obj.RowSizes(y) = 1 / oldSize(1);
    obj.RowSizes = obj.RowSizes / sum(obj.RowSizes);

    obj.update();

end
