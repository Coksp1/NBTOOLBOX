function addLegend(obj)
% Syntax:
%
% addLegend(obj)
%
% Description:
% 
% Add legend to the axes
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(obj.plotType,'image')
        return
    end

    if ~obj.noLegend

        switch lower(obj.graphMethod)

            case 'graph' 

                if ~obj.manuallySetLegend

                    if strcmpi(obj.plotType,'dec')
                        obj.legends = [obj.DB.dataNames(obj.subPlotIndex) obj.variablesToPlot]; 
                    elseif strcmpi(obj.plotType,'candle') 
                        % Do nothing
                    elseif strcmpi(obj.plotType,'scatter')
                        if isa(obj,'nb_graph_cs')
                            obj.legends = [obj.scatterVariables(1:2:end) obj.scatterVariablesRight(1:2:end)];
                        elseif isa(obj,'nb_graph_data')
                            obj.legends = [obj.scatterObs(1:2:end) obj.scatterObsRight(1:2:end)];
                        else
                            obj.legends = [obj.scatterDates(1:2:end) obj.scatterDatesRight(1:2:end)]; 
                        end
                    else

                        if isa(obj,'nb_graph_ts')

                            if isempty(obj.datesToPlot)
                                obj.legends = [obj.variablesToPlot,obj.variablesToPlotRight];
                            else
                                switch lower(obj.language)
                                    case {'norsk','norwegian'}
                                        format = 'pprnorsk';
                                    case {'engelsk','english'}
                                        format = 'pprengelsk';
                                end
                                legTemp = interpretDatesToPlot(obj,'object');
                                for kk = 1:length(legTemp)
                                   legTemp{kk} = toString(legTemp{kk},format); 
                                end
                                obj.legends = legTemp;
                            end

                        else
                            obj.legends = [obj.variablesToPlot,obj.variablesToPlotRight];
                        end
                    end

                end  

                leg    = obj.legends;
                legLoc = obj.legLocation;
                legPos = obj.legPosition;

            case 'graphinfostruct'

                if isempty(obj.inputs.legends)
                    if ~obj.manuallySetLegend
                        leg = obj.DB.dataNames;
                    else
                        leg = obj.legends;
                    end
                else
                    leg = obj.inputs.legends;
                end

                if isempty(obj.inputs.legLocation)
                    legLoc = obj.legLocation;
                else
                    legLoc = obj.inputs.legLocation;
                end

                if isempty(obj.inputs.legPosition)
                    legPos = obj.legPosition;
                else
                    legPos = obj.inputs.legPosition;
                end

            case 'graphsubplots'

                if ~obj.manuallySetLegend
                    obj.legends = obj.DB.dataNames;
                end
                leg = obj.legends;
                if strcmpi(obj.plotType,'dec')
                    leg = ['sum',leg];
                end
                legLoc = obj.legLocation;
                legPos = obj.legPosition;

        end

        % Check if we are using legendText instead (Overwrite the
        % legends property)
        if ~isempty(obj.legendText)

            % Get all the plotted variables (will depend on the 
            % plotType)
            leg = getPlottedVariables(obj,true); 

        end

        % Add fake legends of the plot.
        if isempty(obj.fakeLegend)

             fakeLegends = [];

        else

            fakeLegends(1,size(obj.fakeLegend,2)/2) = nb_legendDetails();
            kk = 1;
            for ii = 1:2:size(obj.fakeLegend,2)

                properties = obj.fakeLegend{ii + 1};

                colorFL           = [51 51 51]/255;
                directionFL       = 'north';
                edgeColorFL       = 'same';
                faceAlphaFL       = 1;
                faceLightingFL    = 'none';
                fontColorFL       = [0,0,0];
                lineStyleFL       = '-';
                lineWidthFL       = obj.lineWidth;
                markerFL          = 'none';
                markerSizeFL      = obj.markerSize;
                typeFL            = 'line';

                for jj = 1:2:size(properties,2)

                    switch lower(properties{jj})
                        case 'direction'
                            directionFL = properties{jj+1};
                        case {'color','cdata'}
                            colorFL = properties{jj+1};
                            if ischar(colorFL) || iscell(colorFL)
                                colorFL = nb_plotHandle.interpretColor(colorFL);
                            end
                        case 'edgecolor'
                            edgeColorFL = properties{jj+1};
                        case 'facealpha'
                            faceAlphaFL = properties{jj+1};
                        case 'facelighting'
                            faceLightingFL = properties{jj+1};
                        case 'fontcolor'
                            fontColorFL = properties{jj+1};
                        case 'linestyle'
                            lineStyleFL = properties{jj+1};
                        case 'linewidth'
                            lineWidthFL = properties{jj+1};
                        case 'marker'
                            markerFL = properties{jj+1}; 
                        case 'type'
                            typeFL = properties{jj+1};
                        otherwise
                            error([mfilename ':: Bad property of the fake legend; ' properties{jj}])
                    end

                end

                fakeLegends(1,kk).fontColor              = fontColorFL;
                fakeLegends(1,kk).patchColor             = colorFL;
                fakeLegends(1,kk).patchDirection         = directionFL;
                fakeLegends(1,kk).patchEdgeColor         = edgeColorFL;
                fakeLegends(1,kk).patchEdgeLineStyle     = lineStyleFL;
                fakeLegends(1,kk).patchEdgeLineWidth     = lineWidthFL;
                fakeLegends(1,kk).patchFaceAlpha         = faceAlphaFL;   
                fakeLegends(1,kk).patchFaceLighting      = faceLightingFL;
                fakeLegends(1,kk).type                   = typeFL;
                fakeLegends(1,kk).lineColor              = colorFL;             
                fakeLegends(1,kk).lineStyle              = lineStyleFL;
                fakeLegends(1,kk).lineWidth              = lineWidthFL;
                fakeLegends(1,kk).lineMarker             = markerFL;
                fakeLegends(1,kk).lineMarkerSize         = markerSizeFL;

                kk = kk + 1;

            end

            % Merge with the other handles sent to the legend 
            if strcmpi(obj.legAuto,'on')
                extraLegends   = obj.fakeLegend(1:2:end);
                leg            = [leg extraLegends];
            end

        end

        % If we have added some patches we need to include them in
        % the 'legends' property
        if isa(obj,'nb_graph_ts')
            if strcmpi(obj.legAuto,'on') && isempty(obj.datesToPlot)
                leg = [obj.patch(1:4:end),leg];
            end
        else
            if strcmpi(obj.legAuto,'on')
                leg = [obj.patch(1:4:end),leg];
            end
        end

        if length(leg) == 1 && strcmpi(obj.plotType,'dec')
            return
        end

        % Look up the legends from the legendText property
        if ~isempty(obj.legendText)
            leg = findLegend(obj.legendText,leg);
        end

        % Find the corresponding variable name of the mnemonics, if
        % given as a legend
        if ~isempty(obj.lookUpMatrix)
            for ii = 1:length(leg)
                leg{ii} = nb_graph.findVariableName(obj,leg{ii});
            end
        end

        % Interpret the local variables syntax
        if ~isempty(obj.localVariables)
            for ii = 1:length(leg)
                leg{ii} = nb_localVariables(obj.localVariables,leg{ii});
            end
        end
        try leg = nb_localFunction(obj,leg);catch; end

        % We need to translate the dates at this stage when
        % legendText is used
        if ~isempty(obj.legendText)

            if isa(obj,'nb_graph_ts')

                if ~isempty(obj.datesToPlot)

                    switch lower(obj.language)
                        case {'norsk','norwegian'}
                            format = 'pprnorsk';
                        case {'engelsk','english'}
                            format = 'pprengelsk';
                    end
                    for kk = 1:length(leg)

                        try
                           legTemp = nb_date.toDate(leg{kk},obj.DB.frequency); 
                           leg{kk} = toString(legTemp,format); 
                        catch %#ok<CTCH>   
                        end

                    end

                end

            end

        end

        % Add the legend to the plot 
        obj.legendObject = nb_legend(obj.axesHandle, leg,...
                  'box',             obj.legBox,...
                  'color',           obj.legColor,...
                  'columns',         obj.legColumns,...
                  'fakeLegends',     fakeLegends,...
                  'fontColor',       obj.legFontColor,...
                  'fontName',        obj.fontName,...
                  'fontSize',        obj.legFontSize,...
                  'fontUnits',       obj.fontUnits,...
                  'columnWidth',     obj.legColumnWidth,...
                  'interpreter',     obj.legInterpreter,...
                  'location',        legLoc,...
                  'normalized',      obj.normalized,...
                  'position',        legPos,...
                  'reorder',         obj.legReorder,...
                  'space',           obj.legSpace);
        addlistener(obj.legendObject,'annotationMoved',@obj.notifyUpdatedGraph);
        addlistener(obj.legendObject,'annotationMoved',@obj.notifyLegendPositionChanged);

    end

    % SUB
    %--------------------------------------------------------------
    function leg = findLegend(legendText,leg)

        nLeg = length(leg);
        for mm = 1:nLeg

            ind = find(strcmp(leg{mm},legendText(1:2:end)),1);
            if ~isempty(ind)
                try leg{mm} = legendText{ind*2}; catch; end %#ok<CTCH>
            end

        end

    end

end
