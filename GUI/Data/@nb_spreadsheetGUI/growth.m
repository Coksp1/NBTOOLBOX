function growth(gui,~,~,numOfPeriods)
% Syntax:
%
% growth(gui,~,~,numOfPeriods)
%
% Description:
%
% Part of DAG. Log diff of the data of the table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = growth(gui.data,numOfPeriods);
    updateTable(gui);

end
