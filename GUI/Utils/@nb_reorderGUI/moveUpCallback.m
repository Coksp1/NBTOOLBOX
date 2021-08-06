function moveUpCallback(gui,~,~)
% Syntax:
%
% moveUpCallback(gui,hObject,event)
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

    if index == 1
        return
    end
    
    % Move the variable up one step
    string{index}     = string{index - 1};
    string{index - 1} = selected;

    % Update the listbox
    set(gui.listbox,'string',string);
    set(gui.listbox,'value',index - 1);

end
