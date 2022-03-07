function skewness(gui,~,~)  
% Syntax:
%
% skewness(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    d = skewness(gui.data.data);
    if isa(gui.data,'nb_ts')
        gui.transData = nb_ts(d,gui.data.dataNames,gui.data.startDate,gui.data.variables);
    elseif isa(gui.data,'nb_cs')
        gui.transData = nb_cs(d,gui.data.dataNames,gui.data.types,gui.data.variables);
    else % nb_data
        gui.transData = nb_data(d,gui.data.dataNames,gui.data.startObs,gui.data.variables);
    end
    updateTable(gui);

end
