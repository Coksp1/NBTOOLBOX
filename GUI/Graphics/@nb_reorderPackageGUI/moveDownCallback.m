function moveDownCallback(gui,~,~)
% Syntax:
%
% moveDownCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string   = get(gui.listbox,'string');
    index    = get(gui.listbox,'value');
    selected = string{index};

    % Move the graph down one step
    moveDown(gui.package,selected);
    
    % Update the listbox
    value = index+1;
    if value > length(string)
        value = length(string);
    end
    set(gui.listbox,...
        'string',gui.package.identifiers,...
        'value', value);

    notify(gui,'packageChanged')

end
