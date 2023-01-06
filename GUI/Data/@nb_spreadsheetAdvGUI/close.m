function close(gui,~,~)
% Syntax:
%
% close(gui,hObject,event)
%
% Description:
%
% Part of DAG. Close request callback called when user try to close 
% spreadsheet window
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if gui.changed && ~gui.openElsewhere
        if isa(gui.parent,'nb_GUI')
            nb_confirmWindow('Do you want to save the changes?',{@notSaveCurrent,gui},{@saveCurrent,gui.parent,gui},[gui.parent.guiName ': Save dataset'])  
        else
            delete(gui.figureHandle)
        end 
    elseif gui.changed && gui.openElsewhere
        nb_confirmWindow('Do you want to save the changes to the graph?',{@notSaveCurrent,gui},{@saveCurrentToGraph,gui},[gui.parent.guiName ': Save changes to graph'])    
    else
        delete(gui.figureHandle)
    end

    function saveCurrent(hObject,~,mainGui,gui)

        if ~ishandle(gui.parent.figureHandle)
            nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                            'the dataset to. Use export to save your work.'])
            close(get(hObject,'parent'));
            return
        end
        
        if isempty(gui.dataName)
            
            % Close question window
            close(get(hObject,'parent'));
            
            gui.changed = 0;
            
            savegui = nb_saveAsDataGUI(gui.parent,gui.data);
            addlistener(savegui,'saveNameSelected',@gui.close);
            return
            
        end
        
        % Save data to main GUI
        appData                = mainGui.data;
        appData.(gui.dataName) = gui.data;
        mainGui.data           = appData;

        % Close question window
        close(get(hObject,'parent'));

        % Close and delete spreadsheet window
        try delete(gui.figureHandle); catch; end %#ok<CTCH>
        delete(gui)

    end

    function saveCurrentToGraph(hObject,~,gui)

        % Save data to graph (which listen to the saveToGraph event 
        % triggered her)
        notify(gui,'saveToGraph');

        % Close question window
        close(get(hObject,'parent'));

        % Close and delete spreadsheet window is taken care of in the
        % callback function resetDataCallback
        %try delete(gui.figureHandle); catch; end %#ok<CTCH>  
        %delete(gui)

    end

    function notSaveCurrent(hObject,~,gui)

        % Close question window
        close(get(hObject,'parent'));

        % Close and delete spreadsheet window
        try delete(gui.figureHandle); catch; end %#ok<CTCH>
        delete(gui)

    end

end
