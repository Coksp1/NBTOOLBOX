function export(gui,~,~)
% Syntax:
%
% export(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up the export dialog window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        nb_errorWindow('No data to export.')
        return
    end
    
    nb_exportDataGUI(gui.parent,gui.data);

end
