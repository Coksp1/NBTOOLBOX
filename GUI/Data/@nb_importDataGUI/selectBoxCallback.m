function selectBoxCallback(gui,~,~)
% Syntax:
%
% selectBoxCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Updates the table when the selected sheet changes.
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the selected sheet values
    if isequal(gui.currentPanel,gui.advSelectPanel)
        index = get(gui.advSheetSelectBox,'value');
    elseif isequal(gui.currentPanel,gui.initSelectPanel)
        index = get(gui.initSheetSelectBox,'value');
    else
        nb_errorWindow('This should not be possible')
        return
    end
    
    notify(gui,'startHeavyJob')
    pause(0.05)
    
    selectedSheet = gui.sheetList{index};
    try
        gui.dataC = nb_xlsread([gui.pathname gui.filename],selectedSheet,'',false,'default',gui.excel);
    catch Err
        nb_errorWindow(sprintf(['Cannot read the selected sheet. It may be due to the file beeing open, \n'...
                       'if this is the case please close the excel file and try again.']),Err)
        notify(gui,'stopHeavyJob')           
        return
    end

    % Update table data and columns
    try
        updateTable(gui);
        if isequal(gui.currentPanel,gui.advSelectPanel)
            set(gui.transposeButton,'value',0);
        end
    catch
        notify(gui,'stopHeavyJob')
        % Window is closed down, so just prevent error to be thrown...
    end
    
    notify(gui,'stopHeavyJob')
    
end

