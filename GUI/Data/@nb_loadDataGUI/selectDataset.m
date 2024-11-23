function selectDataset(gui,~,~)
% Syntax:
%
% selectDataset(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get selected dataset
    index   = get(gui.listBox,'Value');
    string  = get(gui.listBox,'String');
    dataset = string{index};
    if isempty(dataset)
        close(gui.fig);
        return
    end

    % Get dataset
    appData  = gui.parent.data;
    gui.data = appData.(dataset);
    gui.name = dataset;
    
    % Close window
    close(gui.fig);
    
    % Notify listeners
    notify(gui,'sendLoadedData');

end
