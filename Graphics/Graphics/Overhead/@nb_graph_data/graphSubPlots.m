function graphSubPlots(obj)
% Syntax:
% 
% graphSubPlots(obj)
% 
% Description:
% 
% Create graphs of all the variables given in variablesToPlot
% property, in different subplots. (Each dataset against each 
% other). The number of subplot is given by the property 
% subPlotSize.
% 
% Input:
% 
% - obj      : An object of class nb_graph_data
%
% Output:
%
% The wanted graphs plotted on the screen.
% 
% Examples:
% 
% data = nb_data([2 3 2;1 4 5;2 3 2],'',1,...
%               {'Var1','Var2','Var3');
% obj  = nb_graph_data(data);
% obj.graphSubPlots();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj = size(obj,2);
    if nobj > 1
        for ii = 1:nobj
            graphSubPlots(obj(ii));
        end
        return
    end

    %--------------------------------------------------------------
    % If the 'DB' property is empty there is nothing to graph
    %--------------------------------------------------------------
    if isempty(obj.DB)
        return;
    end

    %--------------------------------------------------------------
    % Clear some handles of the object
    %--------------------------------------------------------------
    clearHandles(obj);

    %--------------------------------------------------------------
    % Check if we are going to plot different plot types
    %--------------------------------------------------------------
    if ~isempty(obj.plotTypes)
        plotTypeTemp = 'combination';
    else
        plotTypeTemp = obj.plotType;
    end
    
    %--------------------------------------------------------------
    % If you want some graph some expressions, you must calculate
    % them and add them as seperate timeseries
    %--------------------------------------------------------------
    notFound  = ~ismember(obj.variablesToPlot,obj.DB.variables);
    addedVars = obj.variablesToPlot(logical(notFound));
    if ~isempty(addedVars)
        obj.DB = obj.DB.createVariable(addedVars,addedVars,obj.parameters);
    end

    %--------------------------------------------------------------
    % Reference to the method used
    %--------------------------------------------------------------
    obj.graphMethod = 'graphSubPlots';

    %--------------------------------------------------------------
    % Adjust the font size if graphStyle is set to 'presentation'.
    % Will also interpret the fontScale property
    %--------------------------------------------------------------
    oldFontSizes = adjustFontSize(obj);
    
    %--------------------------------------------------------------
    % Decide the start and end indexes of the plots
    %--------------------------------------------------------------
    obj.startIndex = obj.startGraph - obj.DB.startObs + 1;
    obj.endIndex   = obj.endGraph - obj.DB.startObs + 1;

    %--------------------------------------------------------------
    % Get the bands given the properties of the object. only when
    % the 'fanDataset' property is given
    %--------------------------------------------------------------
    constructBands(obj);
    
    %--------------------------------------------------------------
    % Decide the x-ticks (integer or dates)
    %--------------------------------------------------------------
    if isempty(obj.variableToPlotX) || ~iscell(obj.variableToPlotX)
        createxTickOfGraph(obj);
    end
    
    %--------------------------------------------------------------
    % Get the default color order
    %--------------------------------------------------------------
    tempData = nan(1,obj.DB.numberOfDatasets);
    getColors(obj,tempData,[])

    %--------------------------------------------------------------
    % Evaluate nan and multiplication options + shrink the data to
    % the variables given by the properties 'variablesToPlot' and 
    % 'variablesToPlotRight' + shrink the data given the 
    % 'startGraph' and 'endGraph' options
    %--------------------------------------------------------------
    evaluateDataTransAndShrinkOptions(obj);

    %==============================================================
    % Graphing starts here
    %==============================================================
    tempData                = obj.dataToGraph;
    numberOfPlotsPerSubPlot = obj.subPlotSize(1)*obj.subPlotSize(2);
    obj.numberOfGraphs      = ceil(size(obj.variablesToPlot,2)/numberOfPlotsPerSubPlot);
    for ii = 1:obj.numberOfGraphs

        obj.fieldIndex = ii;
        
        %----------------------------------------------------------
        % Test if we go outside the bounds of the data:
        %----------------------------------------------------------
        if (ii - 1)*numberOfPlotsPerSubPlot + numberOfPlotsPerSubPlot > size(obj.variablesToPlot,2)
            numberOfIteration = size(obj.variablesToPlot,2) - (ii - 1)*numberOfPlotsPerSubPlot;
        else
            numberOfIteration = numberOfPlotsPerSubPlot;
        end

        %---------------------------------------------------------- 
        % Initialize the figures and set the figure properties
        %----------------------------------------------------------
        if strcmpi(obj.figureName,'variableNames')

            figName = 'Variables; ';
            for jj = 1:numberOfIteration - 1
                figName = [figName obj.variablesToPlot{(ii - 1)*numberOfPlotsPerSubPlot + jj} ', ']; %#ok
            end
            obj.figureName = [figName obj.variablesToPlot{(ii - 1)*numberOfPlotsPerSubPlot + numberOfIteration}];

        end
        
        if obj.manuallySetFigureHandle == 0
            
            if isempty(obj.figurePosition)
                inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters'};
            else
                inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters','position',obj.figurePosition};
            end
            
            if ~isempty(obj.plotAspectRatio)
                inputs = [inputs 'advanced',obj.advanced]; %#ok
                obj.figureHandle = [obj.figureHandle, nb_graphPanel(obj.plotAspectRatio,inputs{:})];
            else
                obj.figureHandle = [obj.figureHandle, nb_figure(inputs{:})];
            end
            
        else
            
            if ~isempty(obj.figureHandle.children)
                axesHandles = obj.figureHandle.children;
                for oo = 1:size(axesHandles,2)
                    if isvalid(axesHandles(oo))
                        axesHandles(oo).deleteOption = 'all';
                        delete(axesHandles(oo));
                    end
                end
            end
            
        end

        %==========================================================
        % Then produce the subplots
        %==========================================================
        for jj = 1:numberOfIteration

            % Do each subplot has its own domain?
            %------------------------------------------------------
            if iscell(obj.variableToPlotX)
                old                 = obj.variableToPlotX;
                obj.variableToPlotX = obj.variableToPlotX{(ii - 1)*numberOfPlotsPerSubPlot + jj};
                createxTickOfGraph(obj);
                obj.variableToPlotX = old;
            end
            
            %------------------------------------------------------
            % Make the 3 dimensional data 2 dimensional, graph
            % different datasets against each other
            %------------------------------------------------------
            if size(tempData,1) == 1
                obj.dataToGraph = squeeze(tempData(:,(ii - 1)*numberOfPlotsPerSubPlot + jj,:))'; 
            else
                obj.dataToGraph = squeeze(tempData(:,(ii - 1)*numberOfPlotsPerSubPlot + jj,:)); 
            end

            %------------------------------------------------------
            % Make a nb_axes handle to plot on
            %------------------------------------------------------
            if iscell(obj.position) && nb_sizeEqual(obj.position,[1,numberOfPlotsPerSubPlot])
                obj.axesHandle = nb_axes('parent',obj.figureHandle(end),'position',obj.position{jj});
            else
                if obj.subPlotSpecial
                    obj.axesHandle = nb_subplotSpecial(obj.subPlotSize(1),obj.subPlotSize(2),jj,'parent',obj.figureHandle(end));
                else
                    obj.axesHandle = nb_subplot(obj.subPlotSize(1),obj.subPlotSize(2),jj,'parent',obj.figureHandle(end));
                end
            end
            obj.axesHandle.update = 'off';

            %------------------------------------------------------
            % Add fan layers, if wanted to the plotted variable for
            % the last datasets of the nb_ts object given by the
            % property 'DB'.
            %------------------------------------------------------
            if ~isempty(obj.fanDatasets)
                % Need to set the variable to get the fan chart of
                obj.fanVariable = obj.variablesToPlot{(ii - 1)*numberOfPlotsPerSubPlot + jj};
            end
            addFanChart(obj);
            
            %------------------------------------------------------
            % Add base line, (default is to add it)
            %------------------------------------------------------
            addBaseLine(obj);

            %------------------------------------------------------
            % Add a horizontal line if wanted
            %------------------------------------------------------
            addHorizontalLine(obj)

            %------------------------------------------------------
            % Add vertical forecast line, if wanted
            %------------------------------------------------------
            addVerticalLine(obj);

            %------------------------------------------------------
            % Do the plotting
            %------------------------------------------------------
            switch lower(plotTypeTemp)

                case 'line'

                    % Plot the lines
                    plotLines(obj);

                case {'grouped','stacked'}

                    % Plot bars
                    barPlot(obj);
                    
                case 'area'

                    % Create area plot
                    areaPlot(obj); 
                    
                case 'combination'

                    % Here we can plot different datasets with
                    % different plot types
                    addPlotTypes(obj);     

                otherwise

                    error([mfilename,':: plot type ' obj.plotType ' is not supported by this method :: (graphSubPlots)'])

            end

            %------------------------------------------------------
            % Add a title to the plot
            %------------------------------------------------------
            obj.title = obj.variablesToPlot{(ii - 1)*numberOfPlotsPerSubPlot + jj};
            addTitle(obj);

            %------------------------------------------------------
            % Add copy subplot UIContextMenu
            %------------------------------------------------------
            cMenu = uicontextmenu('parent',obj.figureHandle(end).figureHandle);
            uimenu(cMenu,'Label','Spreadsheet','tag',obj.variablesToPlot{(ii - 1)*numberOfPlotsPerSubPlot + jj},...
                         'callback',@obj.spreadsheetSubplotGUI);
            if isa(obj.parent,'nb_GUI')
                uimenu(cMenu,'Label','Copy','tag',obj.variablesToPlot{(ii - 1)*numberOfPlotsPerSubPlot + jj},...
                             'callback',@obj.copySubplotCallback,'separator','on');
            end
            obj.UIContextMenu = cMenu;
            
            %------------------------------------------------------
            % Add tick mark labels and make the axes look nice
            %------------------------------------------------------
            setAxes(obj);

            %------------------------------------------------------
            % Add the x-label
            %------------------------------------------------------
            addXLabel(obj);

            %------------------------------------------------------
            % Add the y-label
            %------------------------------------------------------
            addYLabel(obj);
            
        end
        %----End graphing------------------------------------------

        %----------------------------------------------------------
        % Decide the legends for each subplot
        %----------------------------------------------------------
        addLegend(obj);

        %----------------------------------------------------------
        % Add figure title to subplot if wanted
        %----------------------------------------------------------
        if ischar(obj.figureTitle)
            addFigureTitle(obj);
        end
        
        %----------------------------------------------------------
        % Save each subplot down to pdf
        %----------------------------------------------------------
        if ~isempty(obj.saveName)
            saveFigure(obj,int2str(ii)); %
        end
         
    end
    
    %--------------------------------------------------------------
    % Revert the font sizes
    %--------------------------------------------------------------
    revertFontSize(obj,oldFontSizes);

end
