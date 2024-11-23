function finishCallback(gui,~,~)
% Syntax:
%
% finishCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Function that executes when you press the finish button in the import
% window. Checks user selection and transforms the data into a nb_data, 
% nb_ts or nb_cs object with links to the origional excel sheet. 
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Check if the data has been given a new name
    if ~isempty(get(gui.nameBox,'string'))
        gui.name = get(gui.nameBox,'string');
    end
    
    % Check format and import selected data
    sorted = nb_getUIControlValue(gui.sortButton);
    file   = [gui.pathname, gui.filename];
    if nb_getUIControlValue(gui.allButton)
        sheets = {};
    else
        sheets = nb_getUIControlValue(gui.sheets);
    end
    try
        gui.data = nb_readExcelMorePages(file,sorted,sheets);
    catch  Err
        nb_errorWindow(['Could not read ' gui.filename ' file. The data of the excel file is not of the correct format.'],Err);
        return
    end
    
    % Excel files does not store localVariables, so we just assign
    % sessions local variables
    %--------------------------------------------------------------
    gui.data.localVariables = gui.parent.settings.localVariables;
    
    % Save the file
    %----------------------------------------------------------------------
    gui.saveCallback([]); 

    
end
