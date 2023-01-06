function close(gui,~,~)
% Syntax:
%
% close(gui,hObject,event)
%
% Description:
%
% Part of DAG. Close request callback called when user try to close 
% window
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(gui.plotter,'nb_graph_adv')
        if isa(gui.plotter.plotter,'nb_table_data_source')
            string = 'Table';
        else
            string = 'Graph';
        end
    else
        if isa(gui.plotter,'nb_table_data_source')
            string = 'Table';
        else
            string = 'Graph';
        end
    end

    if gui.changed && isa(gui.parent,'nb_GUI')
        nb_confirmWindow('Do you want to save changes?',{@notSaveCurrent,gui},{@saveCurrent,gui},[gui.parent.guiName ': Save ' string])
    else
        if ~isempty(gui.figureHandle)
            delete(gui.figureHandle.figureHandle);
        end
    end

end

function saveCurrent(hObject,~,gui)
        
    if isa(gui.plotter,'nb_graph_adv')
        if isa(gui.plotter.plotter,'nb_table_data_source')
            string1 = 'table';
            string2 = 'table';
            string3 = 'Table';
        else
            string1 = 'figure';
            string2 = 'graph';
            string3 = 'Figure';
        end
    else
        if isa(gui.plotter,'nb_table_data_source')
            string1 = 'table';
            string2 = 'table';
            string3 = 'Table';
        else
            string1 = 'figure';
            string2 = 'graph';
            string3 = 'Figure';
        end
    end
    
    if ~ishandle(gui.parent.figureHandle)
        nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                        'the ' string2 ' to. Use export to save your work.'])
        close(get(hObject,'parent'));
        return
    end

    if strcmpi(gui.type,'advanced')

        if isempty(gui.plotterAdv.figureNameNor)
            nb_errorWindow(['The ' string1 ' name (norwegian) must be provided to be able to save the ' string2 '. Go to Advanced/' string3 ' Name to set it.'])
            return
        end

        if isempty(gui.plotterAdv.figureNameEng)
            nb_errorWindow(['The ' string1 ' name (english) must be provided to be able to save the ' string2 '. Go to Advanced/' string3 ' Name to set it.'])
            return
        end

    end

    if isempty(gui.plotterName)

        % Close question window
        close(get(hObject,'parent'));

        gui.changed = 0;

        % Here I don't need to sync the advanced graphs, as it cannot
        % be included in a packages if it doesn't have a name. 
        if strcmpi(gui.type,'advanced')
            savegui = nb_saveAsGraphGUI(gui.parent,gui.plotterAdv);
        else
            savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
        end
        addlistener(savegui,'saveNameSelected',@gui.close);
        return

    end

    % Save copy of graph object to main GUI
    mainGui   = gui.parent;
    appGraphs = mainGui.graphs;
    if strcmpi(gui.type,'advanced')

        appGraphs.(gui.plotterName) = gui.plotterAdv.copy();
        mainGui.graphs              = appGraphs;

        % If the graph is included in a package we sync it
        % (could have dropped to copy the object, but that
        % has other unwanted consequences)
        syncPackage(mainGui,gui.plotterName);

    else
        appGraphs.(gui.plotterName) = gui.plotter.copy();
        mainGui.graphs              = appGraphs;
    end

    % Close question window
    close(get(hObject,'parent'));

    % Close and delete graph window
    delete(gui.figureHandle.figureHandle);
    delete(gui)

end

function notSaveCurrent(hObject,~,graphicsWindow)

    % Close question window
    close(get(hObject,'parent'));

    % Close and delete graph window
    delete(graphicsWindow.figureHandle.figureHandle);
    delete(graphicsWindow)

end
