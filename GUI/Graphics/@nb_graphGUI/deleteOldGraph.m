function deleteOldGraph(gui,~,~)
% Syntax:
%
% deleteOldGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.parent.graphs = rmfield(gui.parent.graphs,gui.oldSaveName);

end
