function editText(obj, textHandle, ~)
% Make selected cell editable
 
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get cell position in table grid
    [y, x] = obj.getGridPosition(textHandle);
    
    % Finish editing of previously selected cell
    if ~isempty(obj.editedObject) && ishandle(obj.editedObject)
        obj.finishEditing(y, x);
    end
    
    % Make selected cell editable
    if obj.cells(y, x).Editing   
        obj.editedObject = obj.cells(y, x).graphicHandles.text;
        string = obj.cells(y, x).String;
        obj.setCursorIndex([size(string, 1), length(string{end}) + 1], 'unwrapped'); 
        obj.update(y, x);
    end
    
    set(gcf, 'CurrentObject', textHandle);

end
