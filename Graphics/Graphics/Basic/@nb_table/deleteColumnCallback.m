function deleteColumnCallback(table, contextMenu, event)

    [y, x] = obj.getGridPosition(gco);
    table.deleteColumn(x);
    
end
