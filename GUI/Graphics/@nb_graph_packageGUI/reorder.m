function reorder(gui,~,~)
% Syntax:
%
% reorder(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up a new window to reorder the graphs
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    reorderGUI = nb_reorderPackageGUI(gui.parent,gui.package);
    addlistener(reorderGUI,'packageChanged',@gui.packageChangedCallback);
    
end
