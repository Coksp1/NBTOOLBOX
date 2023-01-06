function mergeCallback(gui,hObject,~,loadedData)
% Syntax:
%
% mergeCallback(gui,hObject,~,loadedData)
%
% Description:
%
% Part of DAG. Merge loaded data
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    close(get(hObject,'parent'));

    oldData = gui.plotter.DB;

    % Try to merge the data
    mergegui = nb_mergeDataGUI(gui.parent,oldData,loadedData,'Existing','Loaded');
    addlistener(mergegui,'methodFinished',@gui.addMergedData);

end
