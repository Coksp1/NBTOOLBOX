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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        nb_errorWindow('No data to save.')
        return
    end

    savegui = nb_saveAsDataGUI(gui.parent,gui.data);
    addlistener(savegui,'saveNameSelected',@gui.saveCallback);
    
end
