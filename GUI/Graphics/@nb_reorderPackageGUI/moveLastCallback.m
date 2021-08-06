function moveLastCallback(gui,~,~)
% Syntax:
%
% moveLastCallback(gui,hObject,event)
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
    moveLast(gui.package,selected);
    
    % Update the listbox
    value = length(string);
    set(gui.listbox,...
        'string',gui.package.identifiers,...
        'value', value);
    
    notify(gui,'packageChanged')
    
end
