 function copySelectedWith(gui,~,~)
 % Syntax:
%
% copySelectedWith(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy slected cells with table colum names and row names.  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    sel = gui.selectedCells;
    if isempty(sel)
        return 
    end

    dataObj = getDataObject(gui);
    if strcmpi(gui.tableType,'freeze')
        colNames = get(gui.table,'columnName');
        rowNames = get(gui.table,'rowName');
        colNames = colNames(sel(2,1):sel(2,2));
        rowNames = rowNames(sel(1,1):sel(1,2));
    else
        nb_errorWindow('Copy is not supported by the unfreeze view.')
        return
    end
    
    if isa(dataObj,'nb_ts') || isa(dataObj,'nb_data')
        copied = window(dataObj,rowNames{1},rowNames{end},colNames,gui.page);
    else
        copied = window(dataObj,rowNames,colNames,gui.page);
    end
    nb_copyToClipboard(asCell(copied));

end
