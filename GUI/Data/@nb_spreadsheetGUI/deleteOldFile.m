function deleteOldFile(gui,~,~)
% Syntax:
%
% deleteOldFile(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.parent.data = rmfield(gui.parent.data,gui.oldSaveName);

end
