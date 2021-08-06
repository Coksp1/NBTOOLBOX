function addRowCallback(obj, contextMenu, event, position)
    % Get cell position
    [y, x] = obj.getGridPosition(gco);
    
    switch lower(position)
        case 'above'
            rowNumber = y;
        otherwise
            rowNumber = y + 1;
    end
    
    obj.addRow(rowNumber);
end
