function addStringCallback(gui,hObject,~)
% Syntax:
%
% addStringCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. The function called when the OK button is pushed in the GUI
% window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the added string
    string = get(gui.list1,'string');
    index  = get(gui.list1,'value');
    vars   = string(index);
    string = get(gui.editbox,'string');
    
    if strcmpi(gui.type,'prefix')
        message = nb_checkPreFix(string);
    else
        message = nb_checkPostFix(string);
    end
    if ~isempty(message)
        nb_errorWindow(message)
        return
    end 
    
    % Evaluate the expression
    switch lower(gui.type)
        case 'postfix'   
            gui.data = addPostfix(gui.data,string,vars);
        case 'prefix'  
            gui.data = addPrefix(gui.data,string,vars);
    end
    
    % Close window
    close(get(get(hObject,'parent'),'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end
