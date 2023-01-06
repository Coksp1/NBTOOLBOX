function close(gui,~,~)
% Syntax:
%
% close(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if gui.changed
        nb_confirmWindow('Do you want to save changes?',{@notSaveCurrent,gui},{@saveCurrent,gui},[gui.parent.guiName ': Save Package'])
    else
        delete(gui.figureHandle);
    end

    function saveCurrent(hObject,~,gui)
        
        if ~ishandle(gui.parent.figureHandle)
            nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                            'the graph package to. Use export to save your work.'])
            close(get(hObject,'parent'));
            return
        end
        
        if isempty(gui.packageName)
            
            % Close question window
            close(get(hObject,'parent'));
            
            gui.changed = 0;
            
            savegui = nb_saveAsPackageGUI(gui.parent,gui.package);
            addlistener(savegui,'saveNameSelected',@gui.close);
            return
            
        end
        
        % Save copy of graph package object to main GUI
        mainGui                       = gui.parent;
        appPackages                   = mainGui.graphPackages;
        appPackages.(gui.packageName) = copy(gui.package);
        mainGui.graphPackages         = appPackages;

        % Close question window
        close(get(hObject,'parent'));

        % Close and delete graph package window
        delete(gui.figureHandle);
        delete(gui)

    end

    function notSaveCurrent(hObject,~,gui)

        % Close question window
        close(get(hObject,'parent'));

        % Close and delete spreadsheet window
        delete(gui.figureHandle);
        delete(gui)

    end

end
