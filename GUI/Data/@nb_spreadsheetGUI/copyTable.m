function copyTable(gui,~,~)
% Syntax:
%
% copyTable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy the whole table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(gui.data,'nb_modelDataSource')
        dataObj = fetch(gui.data);
    else
        dataObj = gui.data;
    end
    if isa(dataObj,'nb_ts') || isa(dataObj,'nb_data')
        copied = window(dataObj,'','',{},gui.page);
    else
        copied = window(dataObj,{},{},gui.page);
    end
    nb_copyToClipboard(asCell(copied));

end
