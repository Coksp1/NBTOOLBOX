function graphSelected(gui,~,~)
% Syntax:
%
% graphSelected(gui,hObject,event)
%
% Description:
%
% Part of DAG. Make quick graph GUI of the selected variables.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        nb_errorWindow('No data to graph.')
        return
    end

    dataObj = getDataObject(gui);
    if isDistribution(dataObj)
        sel = gui.selectedCellsU;
    else
        sel = gui.selectedCells;
    end
    
    if isempty(sel)
        nb_errorWindow('No selected data to graph.')
        return 
    end

    if strcmp(gui.tableType,'Freeze')

        if isDistribution(dataObj)
            
            num          = size(sel,1);
            dataT(1,num) = nb_distribution;
            for ii = 1:num
               dataT(1,ii) = dataObj.data(sel(ii,1),sel(ii,2));
            end
            plotter = plot(dataT);
            nb_graphMultiGUI(plotter,gui.parent);
            
        else
        
            if isa(gui.data,'nb_modelDataSource')
                dataObj = fetch(gui.data);
            else
                dataObj = gui.data;
            end
            if strcmpi(gui.tableType,'freeze')
                colNames = get(gui.table,'columnName');
                rowNames = get(gui.table,'rowName');
                colNames = colNames(sel(2,1):sel(2,2));
                rowNames = rowNames(sel(1,1):sel(1,2));
            else
                nb_errorWindow('Copy is not supported by the unfreeze view.')
                return
            end

            if isa(dataObj,'nb_ts') || isa(dataObj,'nb_data')
                graphed = window(dataObj,rowNames{1},rowNames{end},colNames,gui.page);
            else
                graphed = window(dataObj,rowNames,colNames,gui.page);
            end
            nb_graphSubPlotGUI(graphed,gui.parent);
            
        end

    else

        nb_errorWindow('Graph Selected is not supported by the unfreeze view.')

    end

end
