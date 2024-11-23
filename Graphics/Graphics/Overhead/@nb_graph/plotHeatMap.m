function plotHeatMap(obj)
% Syntax:
%
% plotHeatMap(obj)
%
% Description:
% 
% Plot heatmap
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isempty(obj.listeners)
        delete(obj.listeners);
        obj.listeners = [];
    end

    if ~isempty(obj.variablesToPlotRight)
        warning('nb_graph_ts:variablesToPlotRightNotSupported',...
            'The variablesToPlotRight property is not supported for the heatmap')
    end
    if isa(obj,'nb_graph_ts')
        if ~isempty(obj.datesToPlot)
            error('The datesToPlot property is not supported for the heatmap')
        end
    end
    
    % Parse additional options
    [direction,options]    = nb_parseOneOptional('direction','vertical',obj.heatmapOptions{:});
    [reverseScale,options] = nb_parseOneOptional('reverseScale',{},options{:});
    [~,options]            = nb_parseOneOptional('xAxisLocation','',options{:});
    
    % Set the direction of the heatmap
    if strcmpi(direction,'vertical')
        d        = obj.dataToGraph;
        colNames = obj.variablesToPlot;
    else
        d = obj.dataToGraph';
        if isa(obj,'nb_graph_ts') || isa(obj,'nb_graph_bd')
            colNames = get(obj,'dates');
        elseif isa(obj,'nb_graph_data')
            colNames = get(obj,'obsOfGraph');
            colNames = strtrim(cellstr(num2str(colNames')));
        else % nb_graph_cs
            colNames = obj.typesToPlot;
        end
    end
    
    % Parse the reverse scale option from cellstr to logical
    if iscellstr(reverseScale)
        reverseScale = ismember(colNames,reverseScale);
    elseif ~islogical(reverseScale)
        error(['The reverseScale input given to the heatmapOptions ',...
            'property must be either logical or a cellstr.'])
    elseif length(reverseScale) ~= length(colNames)
        error(['The reverseScale input given to the heatmapOptions ',...
            'property must have length equal to ' int2str(length(colNames)),...
            ' when provided as a logical vector.'])
    end
    
    % Plot heatmap
    nb_heatmap(d,...
        'parent',obj.axesHandle,...
        'fontUnits',obj.fontUnits,...
        'fontSize',obj.axesFontSize,...
        'fontName',obj.fontName,...
        'reverseScale',reverseScale,...
        options{:} ...
    );
    
end
