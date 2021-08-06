function log(gui,~,~)
% Syntax:
%
% log(gui,hObject,event)
%
% Description:
%
% Part of DAG. Take logs of data of spreadsheet.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = log(gui.data);
    updateTable(gui);

end
