function pcn(gui,~,~,numOfPeriods)
% Syntax:
%
% pcn(gui,hObject,event,numOfPeriods)
%
% Description:
%
% Part of DAG. Log diff of the data of the table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = pcn(gui.data,numOfPeriods);
    updateTable(gui);

end
