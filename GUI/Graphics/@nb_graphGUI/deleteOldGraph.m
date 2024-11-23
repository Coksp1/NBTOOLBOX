function deleteOldGraph(gui,~,~)
% Syntax:
%
% deleteOldGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    gui.parent.graphs = rmfield(gui.parent.graphs,gui.oldSaveName);

end
