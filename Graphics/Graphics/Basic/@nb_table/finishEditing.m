function finishEditing(obj, y, x)

    % Notify listeners that the cell editing is finished
    string = obj.cells(y, x).String;
    event = nb_tableTextUpdateEvent(string, [y, x]);
    notify(obj, 'tableTextUpdate', event);
    
    obj.editedObject = [];
    obj.editIndex    = [];
    
    obj.update(y, x);

end
