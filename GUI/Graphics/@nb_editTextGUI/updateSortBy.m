function updateSortBy(gui,hObject,~)
% Syntax:
%
% updateSortBy(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    string    = get(hObject,'string');
    index     = get(hObject,'value');
    order     = string{index};
    
    graphSelect = gui.popup.String{gui.popup.Value};
    
    % Update ordering and make sure the current selected graph still shows 
    % in popup.
    if strcmpi(order,'default')
        val = find(strcmpi(gui.defaultNames,graphSelect));
        set(gui.popup,'string',gui.defaultNames);
        set(gui.popup,'value',val);
    else
        val = find(strcmpi(gui.sortedNames,graphSelect));
        set(gui.popup,'string',gui.sortedNames);
        set(gui.popup,'value',val);
    end

end
