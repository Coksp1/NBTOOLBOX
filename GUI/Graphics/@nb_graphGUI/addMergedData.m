function addMergedData(gui,hObject,~)
% Syntax:
%
% addMergedData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function triggered in respons to a methodFinished
% event.
%
% Input:
% 
% - hObject : An nb_mergeDataGUI object
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    mergedData = hObject.data;
    
    if (isa(gui.plotter,'nb_graph_ts') || isa(gui.plotter,'nb_table_ts')) && (isa(mergedData,'nb_cs') || isa(mergedData,'nb_data') || isa(mergedData,'nb_cell'))
        nb_errorWindow('It is not possible to plot cross-sectional, dimensionless data or cell data in a time-series graph/table.');
        return
    elseif (isa(gui.plotter,'nb_graph_cs') || isa(gui.plotter,'nb_table_cs')) && (isa(mergedData,'nb_ts') || isa(mergedData,'nb_data') || isa(mergedData,'nb_cell'))
        nb_errorWindow('It is not possible to plot time-series, dimensionless data or cell data in a cross-sectional graph/table.');
        return
    elseif (isa(gui.plotter,'nb_graph_data') || isa(gui.plotter,'nb_table_data')) && (isa(mergedData,'nb_ts') || isa(mergedData,'nb_cs') || isa(mergedData,'nb_cell'))
        nb_errorWindow('It is not possible to plot time-series, cross-sectional data or cell data in a dimensionless graph/table.');
        return
    elseif isa(gui.plotter,'nb_table_cell') && (isa(mergedData,'nb_ts') || isa(mergedData,'nb_cs') || isa(mergedData,'nb_data'))
        nb_errorWindow('It is not possible to plot time-series, dimensionless or cross-sectional data in a cell table.');
        return    
    end
    
    % Reset the data without changing to default properties
    gui.plotter.resetDataSource(mergedData,0);
    
end
