function moveFirstCallback(gui,~,~)
% Syntax:
%
% moveFirstCallback(gui,hObject,event)
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
    moveFirst(gui.package,selected);
    
    % Update the listbox
    set(gui.listbox,...
        'string',gui.package.identifiers,...
        'value', 1);
    
    notify(gui,'packageChanged')
    
end
