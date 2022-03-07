function save(gui,~,~)
% Syntax:
%
% save(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save package
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be saved.')
        return
    end
    
    if isempty(gui.packageName)
        savegui = nb_saveAsPackageGUI(gui.parent,gui.package);
        addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);
    else

        if gui.changed
            nb_confirmWindow(['Are you sure you want to save the changes to ' gui.packageName '?'],@notSaveCurrent,{@saveCurrent,gui},[gui.parent.guiName ': Save Package']);
        end

    end

    function saveCurrent(hObject,~,gui)

        if ~ishandle(gui.parent.figureHandle)
            nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                            'the graph package to. Use export to save your work.'])
            close(get(hObject,'parent'));            
            return
        end
        
        % Save copy of graph package object to main GUI
        mainGui                       = gui.parent;
        appPackages                   = mainGui.graphPackages;
        appPackages.(gui.packageName) = copy(gui.package);
        mainGui.graphPackages         = appPackages;

        % Update the changed property (Will alos remove the star)
        gui.changed = 0;

        % Close question window
        close(get(hObject,'parent'));

    end

    function notSaveCurrent(hObject,~)

        % Close question window
        close(get(hObject,'parent'));

    end

end
