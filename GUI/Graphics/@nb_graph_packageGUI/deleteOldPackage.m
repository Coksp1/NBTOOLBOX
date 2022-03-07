function deleteOldPackage(gui,~,~)
% Syntax:
%
% deleteOldPackage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    gui.graphPackages = rmfield(gui.graphPackages,gui.oldSaveName);

end
