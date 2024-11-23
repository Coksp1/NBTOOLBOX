function write(gui,~,~)
% Syntax:
%
% write(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up the export dialog window
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        nb_errorWindow('No data to write.')
        return
    end

    dataObj = getDataObject(gui);
    if ~isa(dataObj,'nb_ts')
        nb_errorWindow('It is not possible to write data to a FAME database which is not time-series.')
        return
    elseif isDistribution(dataObj)
        nb_errorWindow('It is not possible to write time-series that represent distributions to a FAME database.')
        return
    end
    
    temp = dataObj.window('','','',gui.page);
    nb_writeDataGUI(gui.parent,temp);

end
