function updateCallback(gui,~,~)
% Syntax:
%
% updateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update data given changes in method calls.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    cellM = gui.tableData;
    try
        tested = setMethodCalls(gui.data,cellM);
    catch Err
        [gui.sources,gui.tableData] = getMethodCalls(gui.data);
        updateGUI(gui);
        nb_errorWindow('The changes you made produced an error. Revert to old inputs.', Err)
        return
    end
    try
        tested = update(tested,'off','on');
    catch Err
        [gui.sources,gui.tableData] = getMethodCalls(gui.data);
        updateGUI(gui);
        nb_errorWindow('The changes you made produced an error. Revert to old inputs.', Err)
        return
    end

    % If we get here the changes where successful
    gui.data      = tested;
    gui.tableData = cellM;

    % Notify listeners
    notify(gui,'methodFinished')

    nb_infoWindow('The editing was successful!') 

end
