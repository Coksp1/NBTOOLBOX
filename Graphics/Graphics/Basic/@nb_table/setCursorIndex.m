function setCursorIndex(obj, index, type)
    switch lower(type)
       case 'unwrapped'
           obj.editIndex = index;
        
       case 'wrapped'
            [y, x] = obj.getGridPosition(obj.editedObject);
            unwrappedString = obj.cells(y, x).String;
            wrappedString = get(obj.cells(y, x).graphicHandles.text, 'String');
            
            obj.editIndex = nb_table.convertCursorIndex(...
                wrappedString, unwrappedString, index);
        
    end
end
