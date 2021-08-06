function pcn(gui,~,~,numOfPeriods)
% Syntax:
%
% pcn(gui,hObject,event,numOfPeriods)
%
% Description:
%
% Part of DAG. Log diff of the data of the table.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = pcn(gui.data,numOfPeriods);
    updateTable(gui);

end
