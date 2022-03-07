function renameGraph(gui,~,~)
% Syntax:
%
% renameGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Rename graph
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

    if isempty(gui.plotter.DB)
        nb_errorWindow(['The ' string ' is empty and cannot be renamed.'])
        return
    end
    
    gui.oldSaveName = gui.plotterName;
    if isempty(gui.oldSaveName)
        nb_errorWindow('Cannot rename an object without a name');
        return
    end
    
    if strcmpi(gui.type,'advanced')
        
        nb_errorWindow(['It is not possible to rename a advanced ' lower(string)])
        return
%         if isempty(gui.plotterAdv.figureNameNor) && isempty(gui.plotterAdv.figureNameEng)
%             nb_errorWindow('The figure names (norwegian and english) must be provided to be able to save the graph. Go to Advanced/Figure Name to set them.')
%             return
%         elseif isempty(gui.plotterAdv.figureNameNor)
%             nb_errorWindow('The figure name (norwegian) must be provided to be able to save the graph. Go to Advanced/Figure Name to set it.')
%             return
%         elseif isempty(gui.plotterAdv.figureNameEng)
%             nb_errorWindow('The figure name (norwegian) must be provided to be able to save the graph. Go to Advanced/Figure Name to set it.')
%             return
%         end
        
    else
        savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
        addlistener(savegui,'saveNameSelected',@gui.deleteOldGraph);
        addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);
    end


end
