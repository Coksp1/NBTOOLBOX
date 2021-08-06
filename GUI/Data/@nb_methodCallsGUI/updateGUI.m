function updateGUI(gui,~,~)
% Syntax:
%
% updateGUI(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update the GUI given changes.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    value     = get(gui.list,'value');
    tableData = gui.tableData(:,:,value);

    % Remove empty rows
    emptyRowIndices = strcmp(tableData(:,1), 'Not editable');
    tableData(emptyRowIndices, :) = [];
    
    set(gui.table,'data',tableData);

end
