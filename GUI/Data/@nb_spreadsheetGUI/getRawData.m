function getRawData(gui,~,~)
% Syntax:
%
% getRawData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set the tranData object empty, so the data property 
% (with the raw data) is displayed in the table
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.transData = [];
    updateTable(gui);

end
