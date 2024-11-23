function setHeatmapAxes(obj)
% Syntax:
%
% setHeatmapAxes(obj)
%
% Description:
%
% Set axes properties in the case of a heatmap.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen          

    % Interpret/translate variables
    rowNames = obj.variablesToPlot;
    if ~isempty(obj.lookUpMatrix)
        for ii = 1:length(rowNames)
            rowNames{ii} = nb_graph.findVariableName(obj,rowNames{ii});
        end
    end

    if ~isempty(obj.localVariables)
        for ii = 1:length(rowNames)
            rowNames{ii} = nb_localVariables(obj.localVariables,rowNames{ii});
        end
    end
    for ii = 1:length(rowNames)
        rowNames{ii} = nb_localFunction(obj,rowNames{ii});
    end

    if isa(obj,'nb_graph_ts') || isa(obj,'nb_graph_bd')
        colNames = get(obj,'dates');
    elseif isa(obj,'nb_graph_data')
        colNames = get(obj,'obsOfGraph');
        colNames = strtrim(cellstr(num2str(colNames')));
    else % nb_graph_cs
        colNames = interpretXTickLabels(obj,obj.typesToPlot);
    end
    
    % Parse additional options
    direction     = nb_parseOneOptional('direction','vertical',obj.heatmapOptions{:});
    xAxisLocation = nb_parseOneOptional('xAxisLocation','',obj.heatmapOptions{:});

    % Set the direction of the heatmap
    if strcmpi(direction,'vertical')
        if isempty(xAxisLocation)
            xAxisLocation = 'top';
        end
        obj.axesHandle.xTick    = 1:length(rowNames);
        obj.axesHandle.xTickSet = 1;
        obj.axesHandle.xLim     = [min(obj.axesHandle.xTick) - 0.5,max(obj.axesHandle.xTick) + 0.5];
        obj.axesHandle.xLimSet  = 1;
    else
        tempNames = colNames;
        colNames  = rowNames;
        rowNames  = tempNames;
        if isempty(xAxisLocation)
            xAxisLocation = 'bottom';
        end
    end
    colNames = nb_rowVector(colNames);

    obj.axesHandle.xTickLabelLocation = xAxisLocation;
    obj.axesHandle.xTickLabel         = rowNames;
    obj.axesHandle.xTickLabelSet      = 1;
    obj.axesHandle.yTickLabelRight    = {};
    obj.axesHandle.yTickLabelRightSet = 1;
    obj.axesHandle.yTickLabel         = flip(colNames,2);
    obj.axesHandle.yTickLabelSet      = 1;

end
