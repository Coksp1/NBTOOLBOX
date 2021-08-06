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

    plotterT = gui.plotter(gui.page);
    if isa(plotterT,'nb_table_data_source')
        string  = 'Table';
    else
        string  = 'Graph';
    end

    if isempty(plotterT.DB)
        nb_errorWindow(['The ' string ' is empty and cannot be saved.'])
        return
    end
    nb_saveAsGraphGUI(gui.parent,plotterT);

end
