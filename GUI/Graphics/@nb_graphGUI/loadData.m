function loadData(gui,~,~)
% Syntax:
%
% loadData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Load data to graph object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    loader = nb_loadDataGUI(gui.parent);
    addlistener(loader,'sendLoadedData',@gui.mergeOrReset);
    
end
