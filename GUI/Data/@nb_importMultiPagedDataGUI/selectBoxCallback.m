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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the selected sheet values
    index         = get(gui.initSheetSelectBox,'value');
    selectedSheet = gui.sheetList{index};
    try
        gui.data = nb_xlsread([gui.pathname gui.filename],selectedSheet,'',false,'default',gui.excel);
    catch Err
        nb_errorWindow(sprintf(['Cannot read the selected sheet. It may be due to the file beeing open, \n'...
                       'if this is the case please close the excel file and try again.']),Err)
        return
    end
    
    % Update table data and columns
    dataT        = gui.data;
    numOfColumns = size(dataT,2);
    colNames     = [gui.colList{1:numOfColumns}]';  
    set(gui.initTable,'data',dataT,...
            'columnName',colNames);
    
end

