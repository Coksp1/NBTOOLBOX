function log(gui,~,~)
% Syntax:
%
% log(gui,hObject,event)
%
% Description:
%
% Part of DAG. Take logs of data of spreadsheet.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = log(gui.data);
    updateTable(gui);

end
