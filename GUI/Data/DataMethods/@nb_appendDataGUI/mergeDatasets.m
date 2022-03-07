function mergeDatasets(gui,hObject,~)
% Syntax:
%
% mergeDatasets(gui,hObject,event)
%
% Description:
%
% Part of DAG. Merge datasets found to be selected in the gui.mergeListBox 
% handle
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected datasets
    index     = get(gui.mergeListBox,'Value');
    string    = get(gui.mergeListBox,'String');
    datasets  = string(index);

    if length(datasets) ~= 1
        nb_errorWindow('You must select one dataset.')
        return
    end

    % Get dataset to merge
    mainGUI       = gui.parent;
    appData       = mainGUI.data;
    gui.data2     = appData.(datasets{1});
    gui.saveName2 = datasets{1};

    % Figure out what gui.types of object we are dealing 
    % with and open up a dialog with the user on how to
    % merge the objects
    mergeDatasetEngine(gui);

    % Close former window
    close(get(hObject,'parent'));

end
