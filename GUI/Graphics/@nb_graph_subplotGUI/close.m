function close(gui,hObject,~)
% Syntax:
%
% close(gui,hObject,event)
%
% Description:
%
% Part of DAG. Close request callback called when user try to close 
% graph panel window
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(gui.plotterName)

        if gui.changed
            nb_confirmWindow('Do you want to save changes?',{@notSaveCurrent,gui},{@saveCurrent,gui},[gui.parent.guiName ': Save graph'])
        else
            delete(hObject);
        end

    else
        delete(hObject);
    end

    function saveCurrent(hObject,~,gui)

        if ~ishandle(gui.parent.figureHandle)
            nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                            'the graph to. Use export to save your work.'])
            close(get(hObject,'parent'));
            return
        end
        
        % Save copy of graph object to main GUI
        mainGui                     = gui.parent;
        appGraphs                   = mainGui.graphs;
        appGraphs.(gui.plotterName) = copy(gui.plotter);
        mainGui.graphs              = appGraphs;

        % Close question window
        close(get(hObject,'parent'));
        
        % Close and delete graph window
        delete(gui.figureHandle.figureHandle);
        delete(gui)

    end

    function notSaveCurrent(hObject,~,gui)

        % Close question window
        close(get(hObject,'parent'));

        % Close and delete graph window
        delete(gui.figureHandle.figureHandle);
        delete(gui)

    end

end
