function saveAs(gui,~,~)
% Syntax:
%
% saveAs(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save as 
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.plotter.graphObjects)
        nb_errorWindow('The graph panel is empty and cannot be saved.')
        return
    end
    
    savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
    addlistener(savegui,'saveNameSelected',@gui.saveObjectCallback);

end
