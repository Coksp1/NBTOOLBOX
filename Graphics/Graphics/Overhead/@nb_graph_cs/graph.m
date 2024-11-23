function graph(obj)
% Syntax:
% 
% graph(obj)
% 
% Description:
% 
% Create a graph or more graphs
% 
% Graphs all the variables given by the variablesToPlot and the
% variablesToPlotRight properties in one plot, and does that for 
% all the datasets of the DB property. I.e. one new plot for each
% dataset (page) of the DB property of the nb_graph_cs object.
% 
% Input:
% 
% - obj      : An object of class nb_graph_cs
%
% Output:
%
% The graph plotted on the screen.
%
% Examples:
% 
% data = nb_cs([2;1;2],'',{'type1','type2','type3'},'Var1');
% obj  = nb_graph_cs(data);
% obj.graph();
%
% See also:
% nb_graph_cs.set
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj  = obj(:); 
    nobj = size(obj,1);
    if nobj > 1
        for ii = 1:nobj
            graph(obj(ii));
        end
        return
    end

    %--------------------------------------------------------------
    % If the 'DB' property is empty there is nothing to graph
    %--------------------------------------------------------------
    if isempty(obj.DB) 
        
        %---------------------------------------------------------- 
        % Initialize the figures and set the figure properties
        %----------------------------------------------------------
        if isempty(obj.figurePosition)
            inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters'};
        else
            inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters','position',obj.figurePosition};
        end
        
        if obj.manuallySetFigureHandle == 0
            if ~isempty(obj.plotAspectRatio)
                inputs = [inputs 'advanced',obj.advanced];
                obj.figureHandle = [obj.figureHandle, nb_graphPanel(obj.plotAspectRatio,inputs{:})];
            else
                obj.figureHandle = [obj.figureHandle, nb_figure(inputs{:})];
            end
        else
            if ~isempty(obj.axesHandle)
                if isvalid(obj.axesHandle)
                    obj.axesHandle.deleteOption = 'all';
                    delete(obj.axesHandle);
                end
            end
        end

        %----------------------------------------------------------
        % Make the axes handle
        %----------------------------------------------------------
        obj.axesHandle = nb_axes('parent',              obj.figureHandle(1),...
                                 'position',            obj.position,...
                                 'UIContextMenu',       obj.UIContextMenu,...
                                 'fontUnits',           obj.fontUnits,...
                                 'fontSize',            obj.axesFontSize,...
                                 'normalized',          obj.normalized);       
        return;
    end

    %--------------------------------------------------------------
    % Reference to the method used
    %--------------------------------------------------------------
    obj.graphMethod = 'graph';

    %--------------------------------------------------------------
    % Adjust the font size
    %--------------------------------------------------------------
    oldFontSizes = scaleFontSize(obj);
    
    %--------------------------------------------------------------
    % Clear some handles of the object
    %--------------------------------------------------------------
    clearHandles(obj);

    %--------------------------------------------------------------
    % Check if we are going to plot different plot types
    %--------------------------------------------------------------
    if ~isempty(obj.plotTypes)
        if strcmpi(obj.barOrientation,'horizontal') && (strcmpi(obj.plotType,'stacked') || strcmpi(obj.plotType,'grouped'))
            % It is not possible to combine deifferent plot types 
            % when the barOrientation property is set to 
            % 'horizontal'
            plotTypeTemp = obj.plotType;
        elseif strcmpi(obj.plotType,'scatter') || strcmpi(obj.plotType,'candle') || strcmpi(obj.plotType,'radar') ...
                || strcmpi(obj.plotType,'pie')
            warning('nb_graph_cs:NotPossibleToCombine',[mfilename ':: It is not possible to combine the plotType ''' obj.plotType....
                                                                   ''' with the plotTypes property set to an non empty cell array. plotType set to ''line''.']);
            obj.plotType = 'line';
            plotTypeTemp = 'line';
        else
            plotTypeTemp = 'combination';
        end
    else
        plotTypeTemp = obj.plotType;
    end

    %--------------------------------------------------------------
    % Test the 'variablesToPlot' and the 'variablesToPlotRight'
    % properties
    %--------------------------------------------------------------
    testVariablesToPlot(obj);

    %--------------------------------------------------------------
    % Decide the x-ticks (types)
    %--------------------------------------------------------------
    obj.xTick        = 1:size(obj.typesToPlot,2);
    obj.typesOfGraph = obj.typesToPlot';  

    %--------------------------------------------------------------
    % Only graph the variables given by the cellstr
    % variablesToPlot and the types given by the cellstr
    % typesToPlot
    %--------------------------------------------------------------
    shrinkDataToGraph(obj);

    %==============================================================
    % Graphing starts here
    %==============================================================
    tempData      = obj.dataToGraph;
    tempDataRight = obj.dataToGraphRight;
    if any(strcmpi(obj.plotType,{'pie','donut'}))

        if obj.DB.numberOfDatasets > 1 && isempty(obj.page)
            warning('nb_graph_cs:graph:OnlyFirstDataset',[mfilename ':: This function will only plot the first datasets of the data object'])
        end

        %----------------------------------------------------------
        % The data to plot
        %----------------------------------------------------------
        obj.dataToGraph = tempData(:,:,1);
        if strcmpi(obj.plotType,'pie')
            obj.numberOfGraphs = size(obj.typesToPlot,2);
        else
            obj.numberOfGraphs = 1;
        end

        %----------------------------------------------------------
        % Get colors
        %----------------------------------------------------------
        getColors(obj,tempData,[]);
        
        %----------------------------------------------------------
        % Add pie chart(s)
        %----------------------------------------------------------
        pieChart(obj);
        
    else

        if isempty(obj.page)
            obj.numberOfGraphs = obj.DB.numberOfDatasets;
            iterated           = 1:obj.numberOfGraphs;
        else
            obj.numberOfGraphs = 1;
            iterated           = obj.page;
        end

        %--------------------------------------------------------------
        % Get the bands given the properties of the object. only when
        % the 'fanDataset' property is given
        %--------------------------------------------------------------
        constructBands(obj);
        
        %==========================================================
        % Plot the variables
        %==========================================================
        kk = 0;
        for ii = iterated

            kk = kk + 1;
            
            obj.dataToGraph      = tempData(:,:,ii);
            obj.dataToGraphRight = tempDataRight(:,:,ii);
            obj.subPlotIndex     = ii;

            %------------------------------------------------------
            % Get default colors
            %------------------------------------------------------
            if strcmpi(obj.plotType,'scatter')
                [tempData,tempDataRight] = obj.getScatterSizes();
                getColors(obj,tempData,tempDataRight);
            elseif ~strcmpi(obj.plotType,'candle') 
                getColors(obj,tempData,tempDataRight);
            end

            %------------------------------------------------------
            % Initialize the figures and set the figure properties
            %------------------------------------------------------
            createFigure(obj);

            %------------------------------------------------------
            % Make the axes handle
            %------------------------------------------------------
            obj.axesHandle = nb_axes('parent',          obj.figureHandle(kk),...
                                 'position',            obj.position,...
                                 'UIContextMenu',       obj.UIContextMenu,...
                                 'colorMap',            obj.colorMap);
            obj.axesHandle.update         = 'off';  
            obj.axesHandle.scaleLineWidth = obj.axesScaleLineWidth;
            obj.axesHandle.scaleFactor    = obj.axesScaleFactor;

            %------------------------------------------------------
            % Add highlighted areas
            %------------------------------------------------------
            addHighlightArea(obj)

            %------------------------------------------------------
            % Add patch given the 'patch' property. Add patch 
            % between some given variables
            %------------------------------------------------------
            addPatch(obj,ii);

            %----------------------------------------------------------
            % Add fan chart
            %----------------------------------------------------------
            addFanChart(obj);
            
            %------------------------------------------------------
            % Add base line if the property 'baseLine' is not set 
            % to 0
            %------------------------------------------------------
            addBaseLine(obj);

            %------------------------------------------------------
            % Add a horizontal line(s) if wanted
            %------------------------------------------------------
            addHorizontalLine(obj);

            %------------------------------------------------------
            % Add vertical line(s)
            %------------------------------------------------------
            addVerticalLine(obj);

            %------------------------------------------------------
            % Here we do the plotting of the 'variablesToPlot'
            % and/or 'variablesToPlotRight' variables
            %------------------------------------------------------
            switch lower(plotTypeTemp)

                case 'area'

                    % Create area plot
                    areaPlot(obj,'left');
                    areaPlot(obj,'right');

                case 'candle'

                    % Create candle plot
                    candlePlot(obj,'left');
                    %candlePlot(obj,'right');

                case 'combination'

                    % Here we can plot different variables with
                    % different plot types
                    addPlotTypes(obj,'left');
                    addPlotTypes(obj,'right');

                case 'line'

                    % Plot the lines
                    plotLines(obj,'left');
                    plotLines(obj,'right');

                case 'radar'

                    % Plot the radar plot (There is of cource 
                    % only possible to plot against the left 
                    % axes)
                    plotRadar(obj);

                case {'stacked','grouped','dec'}

                    % Create bar plot
                    barPlot(obj,'left');
                    barPlot(obj,'right');

                case 'scatter'

                    % Create scatter plot
                    scatterPlot(obj,'left');
                    scatterPlot(obj,'right');
                    
                case 'image'
                    
                    % Create image plot
                    imagePlot(obj);
                    
                case 'heatmap'
                
                    plotHeatMap(obj);    

                otherwise

                    error([mfilename,':: plot type ' obj.plotType ' is not supported by this function'])

            end
            
            %------------------------------------------------------
            % Add date tick mark labels and grid lines
            %------------------------------------------------------
            setAxes(obj)
            
            %----------------------------------------------------------
            % Add annotations
            %----------------------------------------------------------
            addAnnotation(obj);
            
            %------------------------------------------------------
            % Evaluate the extra code if given
            %------------------------------------------------------
            if ~isempty(obj.code)
                eval(obj.code);
            end
            
            %------------------------------------------------------
            % Evaluate legends of plot
            %------------------------------------------------------
            addLegend(obj);

            %------------------------------------------------------
            % Title of the plot if not the property 'noTitle' is 
            % set to 1
            %------------------------------------------------------
            addTitle(obj);

            %------------------------------------------------------
            % Add the x-label, if not 'none'
            %------------------------------------------------------
            addXLabel(obj);

            %------------------------------------------------------
            % Add the y-label, if not 'none'
            %------------------------------------------------------
            addYLabel(obj);
            
            %------------------------------------------------------
            % Add figure title and/or footer
            %------------------------------------------------------
            addAdvancedComponents(obj,obj.language);
            
            %====End graphing======================================

            %------------------------------------------------------
            % Save it down to pdf
            %------------------------------------------------------
            if ~isempty(obj.saveName)
                saveFigure(obj,int2str(ii)); 
            end
            %------------------------------------------------------

        end
        
    end
    
    %--------------------------------------------------------------
    % Revert the font sizes
    %--------------------------------------------------------------
    revertFontSize(obj,oldFontSizes);

end
