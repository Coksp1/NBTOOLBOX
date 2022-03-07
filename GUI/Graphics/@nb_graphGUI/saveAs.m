function saveAs(gui,~,~)
% Syntax:
%
% saveAs(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save as 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

    if strcmpi(gui.type,'advanced')
        savegui = nb_saveAsGraphGUI(gui.parent,gui.plotterAdv);
    else
        savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
    end
    addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);

end
