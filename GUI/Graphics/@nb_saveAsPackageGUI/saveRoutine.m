function saveRoutine(gui,hObject,~)
% Syntax:
%
% saveRoutine(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~ishandle(gui.parent.figureHandle)
        nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                       'the graph package to. Use export to save your work.'])
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
    appPackages = gui.parent.graphPackages;
    
    % Get used save names
    oldSaveNames = fieldnames(appPackages);
    
    % Check if the savename is used
    found = any(strcmpi(newSaveName,oldSaveNames));
    
    if found
        nb_errorWindow(['The save name ''' newSaveName ''' you provided already exist. Try another one!'])
    else
        
        appPackages.(newSaveName) = copy(gui.package);
        gui.parent.graphPackages  = appPackages;
        gui.saveName              = newSaveName;
        notify(gui,'saveNameSelected');
        close(get(hObject,'parent'));
        
    end
    
end
