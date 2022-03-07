function graph(gui,~,~)
% Syntax:
%
% graph(gui,hObject,event)
%
% Description:
%
% Part of DAG. Make graph of whole dataset.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        nb_errorWindow('No data to graph.')
        return
    end
    
    dataObj = getDataObject(gui);
    if isDistribution(dataObj)
        plotter = plot(dataObj.data(:)');
        nb_graphMultiGUI(plotter,gui.parent);
    else
        nb_graphSubPlotGUI(dataObj,gui.parent);
    end

end
