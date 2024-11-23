function [index,special] = nb_interpretKeyPress(textObj,index,event)
% Syntax:
%
% [index,special] = nb_interpretKeyPress(textObj,index,event)
%
% Description:
%
% Update a text object given a index and a event triggered by KeyReleaseFcn
% KeyPressFcn or a nb_keyEvent.
% 
% Input:
% 
% - textObj : A MATLAB text handle (object).
%
% - index   : A 1x2 double with the index for where the string property of
%             the text handle is edited. index(1) is the current row, and
%             index(2) is the current column.
%
% - event   : Eiter a struct thrown by KeyReleaseFcn or KeyPressFcn, or a
%             nb_keyEvent.
% 
% Output:
% 
% - index   : The updated index. May change due to arrow being pressed.
%
% - special : Either:
%             - ''               : No special key is pressed.
%             - 'escape'         : Esc is pressed.
%             - 'tab'            : Tab is pressed.
%             - struct           : If the special field is set to 
%                                  'multilinePaste', a multilined element 
%                                  is pasted into the given location. See
%                                  the pasted field for the pasted element.
%                                  
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string = get(textObj,'string');
    if ~iscellstr(string)
        error('The string property of the text handle must be cellstr.')
    end
    
    % Remove '|' from string before processing
    if string{index(1)}(index(2)) == '|'
        string{index(1)}(index(2)) = [];
    end
    
    % Separate user-intended and auto-wrapped line breaks
    % For use in conjunction with nb_breakText
    wrappedLines = [];
    userData = get(textObj, 'UserData');
    if isfield(userData, 'WrappedLines')
        wrappedLines = userData.WrappedLines;
    end

    special = '';
    
    if strcmpi(event.Key,'escape')
        
        special = 'escape';
        
    elseif strcmpi(event.Key,'uparrow')
        
        index(1) = max(index(1) - 1, 1);
        index(2) = min(index(2), length(string{index(1)}) + 1);
        
    elseif strcmpi(event.Key,'downarrow')
        
        index(1) = min(index(1) + 1, size(string, 1));
        index(2) = min(index(2), length(string{index(1)}) + 1);   
        
    elseif strcmpi(event.Key,'leftarrow')
        
        if index(2) > 1
            index(2) = index(2) - 1;
        elseif index(1) > 1
            index(1) = index(1) - 1;
            index(2) = length(string{index(1)}) + 1;
        end
        
    elseif strcmpi(event.Key,'rightarrow')
        
        if index(2) <= length(string{index(1)})
            index(2) = index(2) + 1;
        elseif index(1) < size(string, 1)
            index(1) = index(1) + 1;
            index(2) = 1;
        end
        
    elseif strcmpi(event.Key,'return')
        
        % Split line
        line   = string{index(1)};        
        above  = string(1:index(1)-1);
        below  = string(index(1)+1:end);
        left   = {line(1:index(2)-1)};
        right  = {line(index(2):end)};
        
        string = [above; left; right; below];
           
        % Update indices
        wrappedLines(wrappedLines >= index(1)) = ...
            wrappedLines(wrappedLines >= index(1)) + 1;
        
        index(1) = index(1) + 1;
        index(2) = 1;     
        
    elseif strcmpi(event.Key, 'backspace')

        if index(2) > 1
            
            % Remove preceding character
            string{index(1)}(index(2) - 1) = [];
            index(2) = index(2) - 1;

        elseif index(1) > 1

            % Merge the current line with the previous
            string{index(1) - 1} = [string{index(1) - 1}, string{index(1)}];
            string(index(1)) = [];

            % Update indices
            wrappedLines(wrappedLines >= index(1)) = ...
                wrappedLines(wrappedLines >= index(1)) - 1;
            
            index(1) = index(1) - 1;
            index(2) = length(string{index(1)}) + 1;      

        end
        
    elseif strcmpi(event.Key, 'delete')

        if index(2) <= length(string{index(1)})
            
            % Remove trailing character
            string{index(1)}(index(2)) = [];

        elseif index(1) < size(string, 1)
               
            % Merge the current line with the next
            string{index(1)} = [string{index(1)}, string{index(1) + 1}];
            string(index(1) + 1) = [];
            
            % Update indices
            wrappedLines(wrappedLines > index(1)) = ...
                wrappedLines(wrappedLines > index(1)) - 1;

        end
        
    elseif strcmpi(event.Key, 'tab')
        
        % Notify special key
        if length(event.Modifier) == 1
            if strcmpi(event.Modifier{1},'shift')
                special = 'shift+tab';
            end
        else
            special = 'tab';
        end
        
    elseif length(event.Modifier) == 1 && strcmpi(event.Modifier{1}, 'control')
    % Copy and paste
        
        switch lower(event.Key)
            case 'c'
                % We want to copy the unwrapped string,
                % so the caller handles the copying
                special = 'copy';
                
            case 'v'
                [string, index, wrappedLines] = ...
                    pasteElement(string, index, wrappedLines);

        end
        
    else
    % Normal character input

        if ~isempty(event.Character)
            line             = string{index(1)};
            string{index(1)} = [line(1:index(2)-1), event.Character, line(index(2):end)];
            index(2)         = index(2) + 1;
        end
        
    end
    
    % Add cursor '|'
    % line             = string{index(1)};
    % string{index(1)} = [line(1:index(2)-1), '|', line(index(2):end)];
    
    % Update text object    
    userData = get(textObj, 'UserData');
    if isstruct(userData) || isempty(userData)
        userData.WrappedLines = wrappedLines;
        set(textObj, 'UserData', userData);
    end
    
    set(textObj, 'string', string);

end

%==========================================================================
function [string,index,wrappedLines,err] = pasteElement(string,index,wrappedLines)

    pasted = nb_pasteFromClipboard('.',char(9),nb_newline,false);
    err    = false;
    
    if ischar(pasted)
        pasted = cellstr(pasted);
    end
        
    if iscellstr(pasted) && or(nb_sizeEqual(pasted,[1,nan]), nb_sizeEqual(pasted,[nan,1]))

        if nb_sizeEqual(pasted,[1,nan])
            pasted = pasted';
        end

        above = string(1:index(1) - 1);
        below = string(index(1)+1:end);

        line  = string{index(1)};
        left  = line(1:index(2) - 1);
        right = line(index(2):end);

        middle = {[left, pasted{1}]};
        middle = [middle; pasted(2:end)];
        middle{end} = [middle{end}, right];

        string = [above; middle; below];

        % Update indices
        wrappedLines(wrappedLines >= index(1)) = ...
            wrappedLines(wrappedLines >= index(1)) + size(pasted, 1) - 2;

        index(1) = index(1) + size(pasted, 1) - 1;
        index(2) = length(middle{end}) - length(right) + 1;

    else
        nb_errorWindow('Cannot past the object from the clipboard.')
        err = true;
    end

end
