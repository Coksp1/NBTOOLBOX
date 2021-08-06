function export(gui,~,~)
% Syntax:
%
% export(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up the export dialog window.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        nb_errorWindow('No data to export.')
        return
    end
    
    nb_exportDataGUI(gui.parent,gui.data);

end
