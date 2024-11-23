function copySelectedLocally(gui,~,~)
% Syntax:
%
% copySelectedLocally(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Copy part of the table for local use. (I.e. to an object of class
% nb_dataSource.)
%
% The updateability of the object is not destroyed.
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
        gui.parent.copiedObject = window(dataObj,rowNames{1},rowNames{end},colNames,gui.page);
    else
        gui.parent.copiedObject = window(dataObj,rowNames,colNames,gui.page);
    end

end
