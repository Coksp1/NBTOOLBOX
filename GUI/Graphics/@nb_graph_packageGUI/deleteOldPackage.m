function deleteOldPackage(gui,~,~)
% Syntax:
%
% deleteOldPackage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.graphPackages = rmfield(gui.graphPackages,gui.oldSaveName);

end
