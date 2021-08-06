function copy(gui,~,~)
% Syntax:
%
% copy(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy graph object locally
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.parent.copiedObject = gui.plotter(gui.page).copy;
    
end
