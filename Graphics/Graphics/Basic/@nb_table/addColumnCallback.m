function addColumnCallback(obj, contextMenu, event, position)
    % Get cell position
    [y, x] = obj.getGridPosition(gco);
    
    switch lower(position)
        case 'before'
            columnNumer = x;
        otherwise
            columnNumer = x + 1;
    end
    
    obj.addColumn(columnNumer);
end
