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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ishandle(gui.parent.figureHandle)
        nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                       'the graph to. Use export to save your work.'])
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
    appGraphs = gui.parent.graphs;
    
    % Get used save names
    oldSaveNames = fieldnames(appGraphs);
    
    % Check if the savename is used
    found = any(strcmpi(newSaveName,oldSaveNames));
    
    if found
        nb_errorWindow(['The save name ''' newSaveName ''' you provided already exist. Try another one!'])
    else
        saveTemplate(gui.plotter);
        appGraphs.(newSaveName) = copy(gui.plotter);
        gui.parent.graphs       = appGraphs;
        gui.saveName            = newSaveName;
        notify(gui,'saveNameSelected');
        close(get(hObject,'parent'));
        
    end
    
end
