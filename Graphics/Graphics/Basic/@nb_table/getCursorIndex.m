function index = getCursorIndex(obj, type)
    unwrappedIndex = obj.editIndex;
    
    switch lower(type)
       case 'unwrapped'
           index = unwrappedIndex;
        
       case 'wrapped'
            [y, x] = obj.getGridPosition(obj.editedObject);
            unwrappedString = obj.cells(y, x).String;
            wrappedString = get(obj.cells(y, x).graphicHandles.text, 'String');
            
            index = nb_table.convertCursorIndex(...
                unwrappedString, wrappedString, unwrappedIndex);
        
    end
end
