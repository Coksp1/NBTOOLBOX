function deleteRowCallback(table, contextMenu, event)
    
    [y, x] = obj.getGridPosition(gco);
    table.deleteRow(y);
    
end
