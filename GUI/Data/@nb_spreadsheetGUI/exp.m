function exp(gui,~,~)
% Syntax:
%
% exp(gui,hObject,event)
%
% Description:
%
% Part of DAG. Raise e to the data of the table.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = exp(gui.data);
    updateTable(gui);

end
