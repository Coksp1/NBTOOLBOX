function loadData(gui,~,~)
% Syntax:
%
% loadData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Load data to graph object.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    loader = nb_loadDataGUI(gui.parent);
    addlistener(loader,'sendLoadedData',@gui.mergeOrReset);
    
end
