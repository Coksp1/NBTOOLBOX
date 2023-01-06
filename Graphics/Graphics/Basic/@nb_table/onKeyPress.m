function onKeyPress(obj, source, event)

    if isempty(obj.editedObject)
        return
    end
    
    [y, x] = obj.getGridPosition(gco(source));
    currentObject = obj.cells(y,x).graphicHandles.text;
    
    % Abort if some other object than the current edited object is selected
    if obj.editedObject ~= currentObject 
        obj.finishEditing(y, x);
        return;
    end
    
    [y, x] = obj.getGridPosition(obj.editedObject);
    editedCell = obj.cells(y, x);
    
    if editedCell.Editing
        
        wrappedIndex = obj.getCursorIndex('wrapped');
        [wrappedIndex, special] = nb_interpretKeyPress(...
            obj.editedObject, wrappedIndex, event);
        
        unwrappedString = unwrapString(obj.editedObject);
        obj.cells(y, x).String = unwrappedString;
        obj.setCursorIndex(wrappedIndex, 'wrapped'); 
        obj.updateCell(y, x, 'text');
        
        if ~isempty(special) 
            interpretSpecial(obj,x,y,special,source);
        end 

    end

end

function output = unwrapString(textHandle)
    wrappedString = get(textHandle, 'String');
    
    % Separate user-intended and auto-wrapped line breaks
    wrappedLines = [];
    userData = get(textHandle, 'UserData');
    if isfield(userData, 'WrappedLines')
        wrappedLines = userData.WrappedLines;
    end
    
    output = cell(0); 
    outputLine = 1;
    
    for i = 1:size(wrappedString, 1)
        if outputLine > size(output, 1)
            output{outputLine, 1} = wrappedString{i};
        else
            output{outputLine, 1} = [output{outputLine, 1} ' ' wrappedString{i}];
        end
        
        % Only insert user-intended line breaks
        if ~any(wrappedLines == i)
            outputLine = outputLine + 1;
        end
    end
end

%==========================================================================
function interpretSpecial(obj,x,y,special,~)

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(special,'escape')      
        obj.finishEditing(y, x);
    elseif strcmpi(special, 'copy')
        nb_copyToClipboard(obj.cells(y, x).String);
    elseif strcmpi(special,'tab')

        % Switch to next text box
        s = obj.size;
        if y == s(1) && x == s(2)
            yNew = 1;
            xNew = 1;
        elseif x == s(2)
            yNew = y + 1;
            xNew = 1;
        else
            yNew = y;
            xNew = x + 1;
        end
        
        obj.editText(obj.cells(yNew, xNew).graphicHandles.text);

    elseif strcmpi(special,'shift+tab')

        % Switch to previous text box
        s = obj.size;
        if y == 1 && x == 1
            yNew = s(1);
            xNew = s(2);
        elseif x == 1
            yNew = y - 1;
            xNew = s(2);
        else
            yNew = y;
            xNew = x - 1;
        end

        obj.editText(obj.cells(yNew, xNew).graphicHandles.text);   

    end

end
