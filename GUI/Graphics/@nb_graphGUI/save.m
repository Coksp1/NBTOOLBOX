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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(gui.plotter,'nb_graph_adv')
        if isa(gui.plotter.plotter,'nb_table_data_source')
            string1 = 'table';
            string2 = 'table';
            string  = 'Table';
            string3 = 'Table';
        else
            string1 = 'figure';
            string2 = 'graph';
            string  = 'Graph';
            string3 = 'Figure';
        end
    else
        if isa(gui.plotter,'nb_table_data_source')
            string1 = 'table';
            string2 = 'table';
            string  = 'Table';
            string3 = 'Table';
        else
            string1 = 'figure';
            string2 = 'graph';
            string  = 'Graph';
            string3 = 'Figure';
        end
    end

    if isempty(gui.plotter.DB)
        nb_errorWindow(['The ' string ' is empty and cannot be saved.'])
        return
    end
    
    if strcmpi(gui.type,'advanced')
        
        if isempty(gui.plotterAdv.figureNameNor) && isempty(gui.plotterAdv.figureNameEng)
            nb_errorWindow(['The ' string1 ' names (norwegian/english) must be provided to be able to save the ' string2 '. Go to Advanced/' string3 ' Name to set them.'])
            return
        elseif isempty(gui.plotterAdv.figureNameNor)
            nb_errorWindow(['The ' string1 ' name (norwegian) must be provided to be able to save the ' string2 '. Go to Advanced/' string3 ' Name to set it.'])
            return
        elseif isempty(gui.plotterAdv.figureNameEng)
            nb_errorWindow(['The ' string1 ' name (english) must be provided to be able to save the ' string2 '. Go to Advanced/' string3 ' Name to set it.'])
            return
        end
        
    end
    
    if isempty(gui.plotterName)
        
        if strcmpi(gui.type,'advanced')
            savegui = nb_saveAsGraphGUI(gui.parent,gui.plotterAdv);
        else
            savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
        end
        addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);
        
    else
        if gui.changed
            nb_confirmWindow(['Are you sure you want to save the changes to ' gui.plotterName '?'],@notSaveCurrent,{@saveCurrent,gui},[gui.parent.guiName ': Save Graph']);
        end
    end

    function saveCurrent(hObject,~,gui)

        if ~ishandle(gui.parent.figureHandle)
            nb_errorWindow(['You have closed the main window of DAG, which you are trying to save '...
                            'the graph/table to. Use export to save your work.'])
            close(get(hObject,'parent'));
            return
        end
        
        % Save data to main GUI
        appGraph = gui.parent.graphs;
        if strcmpi(gui.type,'advanced')
            saveTemplate(gui.plotterAdv);
            appGraph.(gui.plotterName) = copy(gui.plotterAdv);
            gui.parent.graphs          = appGraph;
            
            % If the graph is included in a package we sync it
            % (could have dropped to copy the object, but that
            % has other unwanted consequences)
            syncPackage(gui.parent,gui.plotterName);
            
        else
            saveTemplate(gui.plotter);
            appGraph.(gui.plotterName) = copy(gui.plotter);
            gui.parent.graphs          = appGraph;
        end
        
        % Update the changed property
        removeStar(gui);

        % Close question window
        close(get(hObject,'parent'));

    end

    function notSaveCurrent(hObject,~)

        % Close question window
        close(get(hObject,'parent'));

    end

end
