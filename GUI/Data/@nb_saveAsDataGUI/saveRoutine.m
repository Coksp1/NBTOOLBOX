function saveRoutine(gui,hObject,~)
% Syntax:
%
% saveRoutine(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~ishandle(gui.parent.figureHandle)
        nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                       'the dataset to. Use export to save your work.'])
        return
    end

    % Get save name
    newSaveName           = get(gui.editBox,'string');
    [newSaveName,message] = nb_checkSaveName(newSaveName);
    if ~isempty(message)
        nb_errorWindow(message)
        return
    end
    
    % Get the data tank
    appData = gui.parent.data;
    
    % Get used save names
    oldSaveNames = fieldnames(appData);
    
    % Check if the savename is used
    found = any(strcmpi(newSaveName,oldSaveNames));
    
    if found
        nb_errorWindow(['The save name ''' newSaveName ''' you provided already exist. Try another one!'])
    else
        
        appData.(newSaveName) = gui.data;
        gui.parent.data       = appData;
        gui.saveName          = newSaveName;
        close(get(hObject,'parent'));
        notify(gui,'saveNameSelected');
        
    end
    
end
