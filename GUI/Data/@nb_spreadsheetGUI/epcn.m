function epcn(gui,~,~,numOfPeriods)
% Syntax:
%
% epcn(gui,~,~,numOfPeriods)
%
% Description:
%
% Part of DAG. Calculate growth rate of the data of the table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    gui.transData = epcn(gui.data,numOfPeriods);
    updateTable(gui);

end
