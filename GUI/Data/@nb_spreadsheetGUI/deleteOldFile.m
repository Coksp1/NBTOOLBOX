function deleteOldFile(gui,~,~)
% Syntax:
%
% deleteOldFile(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    gui.parent.data = rmfield(gui.parent.data,gui.oldSaveName);

end
