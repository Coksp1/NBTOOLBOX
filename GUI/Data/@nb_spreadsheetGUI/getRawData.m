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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    gui.transData = [];
    updateTable(gui);

end
