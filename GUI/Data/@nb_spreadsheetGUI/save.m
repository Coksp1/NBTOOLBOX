function save(gui,~,~)
% Syntax:
%
% save(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        nb_errorWindow('No data to save.')
        return
    end

    if isempty(gui.dataName)
        savegui = nb_saveAsDataGUI(gui.parent,gui.data);
        addlistener(savegui,'saveNameSelected',@gui.saveCallback);
    else

        if gui.changed
            nb_confirmWindow(['Are you sure you want to save the changes to ' gui.dataName '?'],@notSaveCurrent,{@saveCurrent,gui},[gui.parent.guiName ': Save dataset']);
        end

    end

    function saveCurrent(hObject,~,gui)

        if ~ishandle(gui.parent.figureHandle)
            nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                            'the dataset to. Use export to save your work.'])
            close(get(hObject,'parent'));            
            return
        end
        
        % Save data to main GUI
        mainGui                = gui.parent;
        appData                = mainGui.data;
        appData.(gui.dataName) = gui.data;
        mainGui.data           = appData;

        % Update the changed property
        removeStar(gui);

        % Close question window
        close(get(hObject,'parent'));

        notify(gui,'savedData');
        
    end

    function notSaveCurrent(hObject,~)

        % Close question window
        close(get(hObject,'parent'));

    end

end
