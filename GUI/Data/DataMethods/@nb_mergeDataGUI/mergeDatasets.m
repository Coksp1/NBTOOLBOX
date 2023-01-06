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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get selected datasets
    index     = get(gui.mergeListBox,'Value');
    string    = get(gui.mergeListBox,'String');
    datasets  = string(index);

    if length(datasets) ~= gui.type
        if gui.type == 2
            nb_errorWindow('You must select two datasets.')
        else
            nb_errorWindow('You must select one dataset.')
        end
        return
    end

    % Get dataset to merge
    mainGUI   = gui.parent;
    appData   = mainGUI.data;

    if gui.type == 2
        gui.data1     = appData.(datasets{1});
        gui.data2     = appData.(datasets{2});
        gui.saveName1 = datasets{1};
        gui.saveName2 = datasets{2};
    else
        if isempty(gui.data1)
            gui.data1     = appData.(datasets{1});
            gui.saveName1 = datasets{1};
        else
            gui.data2     = appData.(datasets{1});
            gui.saveName2 = datasets{1};
        end
    end

    % Figure out what gui.types of object we are dealing 
    % with and open up a dialog with the user on how to
    % merge the objects
    mergeDatasetEngine(gui);

    % Close former window
    close(get(hObject,'parent'));

end
