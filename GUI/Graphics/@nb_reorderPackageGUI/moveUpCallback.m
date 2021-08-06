function moveUpCallback(gui,~,~)
% Syntax:
%
% moveUpCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string   = get(gui.listbox,'string');
    index    = get(gui.listbox,'value');
    selected = string{index};

    % Move the graph down one step
    moveUp(gui.package,selected);
    
    % Update the listbox
    value = index-1;
    if value < 1
        value = 1;
    end
    set(gui.listbox,...
        'string',gui.package.identifiers,...
        'value', value);

    notify(gui,'packageChanged')
    
end
