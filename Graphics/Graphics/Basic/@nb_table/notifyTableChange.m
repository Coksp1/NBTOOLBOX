function notifyTableChange(obj)
    
    [y, x] = obj.getGridPosition(obj.editedObject);

    % Notify listeners that the cell editing is finished
    string = obj.cells(y, x).String;
    event  = nb_tableEditEvent(string, [y, x]);
    notify(obj,'tableEdit',event);
    
    obj.editedObject = [];
    obj.editIndex    = [];
    
    obj.update(y, x);
    
end
