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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the data 
    %----------------------------------------------------------------------

    % Check if a custom range has been chosen
    selectedDates       = get(gui.dateSelectBox,'string');
    selectedVariables   = get(gui.varSelectBox,'string');
    selectedData        = get(gui.dataSelectBox,'string');

    test = isempty(selectedDates) && isempty(selectedVariables) && isempty(selectedData);
    if test
        range = '';
    elseif ~test
        range = {selectedDates,selectedVariables,selectedData};
    else
        nb_errorWindow('If you manually select the cells to read, i.e. obs/dates/types, variables and data, all must be set.')
        return
    end 

    % Check if the data has been given a new name
    if ~isempty(get(gui.nameBox,'string'))
        gui.name = get(gui.nameBox,'string');
    end
    
    % Check format and import selected data
    sorted = get(gui.sortButton,'value');
    index  = get(gui.initSheetSelectBox,'value');
    sheet  = gui.sheetList{index};
    file   = [gui.pathname gui.filename];
    if isequal(gui.currentPanel,gui.initSelectPanel) || isempty(range)

        if isequal(gui.currentPanel,gui.initSelectPanel)
            tempData = gui.dataC;
        else
            tempData = get(gui.advTable,'data');
        end
        
        if get(gui.nb_cellButton,'value')
            try
                gui.data = nb_cell(file,sheet);
            catch Err
                nb_errorWindow('Some error occurred::',Err);
                return
            end
        else
            try
                gui.data = nb_readExcel(file,sheet,'',false,sorted,tempData);
            catch  Err
                nb_errorWindow(['Could not read ' gui.filename ' file. The data of the excel file is not of the correct format.'],Err);
                return
            end
        end
        
    else
        
        transpose = get(gui.transposeButton,'value');
        try
            gui.data = nb_readExcel(file,sheet,range,transpose,sorted);
        catch  Err
            nb_errorWindow(['Could not read ' gui.filename ' file. The data of the excel file is not of the correct format.'...
                            nb_newLine '(Or it may be due to the excel file beeing open)'],Err);
            return
        end

    end
    
    % Excel files does not store localVariables, so we just assign
    % sessions local variables
    %--------------------------------------------------------------
    gui.data.localVariables = gui.parent.settings.localVariables;
    
    % Save the file
    %----------------------------------------------------------------------
    gui.saveCallback([]); 

    
end
