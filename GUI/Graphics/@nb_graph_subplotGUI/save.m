function save(gui,~,~)
% Syntax:
%
% save(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save subplot
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.plotter.graphObjects)
        nb_errorWindow('The graph panel is empty and cannot be saved.')
        return
    end

    if isempty(gui.plotterName)
        
        savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
        addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);
        
    else

        if gui.changed
            nb_confirmWindow(['Are you sure you want to save the changes to ' gui.plotterName '?'],@notSaveCurrent,{@saveCurrent,gui},[gui.parent.guiName ': Save Graph']);
        end

    end

    function saveCurrent(hObject,~,gui)

        if ~ishandle(gui.parent.figureHandle)
            nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                            'the graph to. Use export to save your work.'])
            close(get(hObject,'parent'));            
            return
        end
        
        % Save data to main GUI
        appGraph                   = gui.parent.graphs;
        appGraph.(gui.plotterName) = copy(gui.plotter);
        gui.parent.graphs          = appGraph;
        
        % If the graph is included in a package we sync it
        % (could have dropped to copy the object, but that
        % has other unwanted consequences)
        syncPackage(gui.parent,gui.plotterName);
        
        % Update the changed property
        gui.changed = 0;

        % Close question window
        close(get(hObject,'parent'));

    end

    function notSaveCurrent(hObject,~)

        % Close question window
        close(get(hObject,'parent'));

    end

end
