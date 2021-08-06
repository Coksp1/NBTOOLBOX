function moveLastCallback(gui,~,~)
% Syntax:
%
% moveLastCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string   = get(gui.listbox,'string');
    index    = get(gui.listbox,'value');
    
    if isempty(string)
        return
    end
    
    selected = string{index};
    
    if index == length(string)
        return
    end
    
    % If the string is a column vector, make it a row vector
    if size(string,1) > 1 
        string = string';
    end
    
    % Move the variable to the bottom
    string = [string{1:index - 1}, string(index + 1:end), selected];
    
    % Update the listbox
    set(gui.listbox,'string',string);
    set(gui.listbox,'value',length(string));
    
end
