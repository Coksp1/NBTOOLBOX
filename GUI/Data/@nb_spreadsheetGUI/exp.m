function exp(gui,~,~)
% Syntax:
%
% exp(gui,hObject,event)
%
% Description:
%
% Part of DAG. Raise e to the data of the table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = exp(gui.data);
    updateTable(gui);

end
