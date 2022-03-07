function graphInfoStruct(obj)
% Syntax:
% 
% graphInfoStruct(obj)
% 
% Description:
% 
% Create graphs based on the property GraphStruct. If it is empty
% nothing wil happend.
%
% This method makes it easy to set up graph packages. For example
% graphing output from models.
%
% See the documentation NB toolbox for more on this method.
% 
% Input:
% 
% - obj      : An object of class nb_graph_cs, where the property 
%              GraphStruct contains the information on how to plot
%              the objects data.
%
% Output:
%
% The wanted graphs plotted on the screen.
% 
% Examples:
% 
% obj.graphInfoStruct();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    %--------------------------------------------------------------
    % If the 'DB' property is empty there is nothing to graph
    %--------------------------------------------------------------
    if isempty(obj.DB)
        return;
    end

    %--------------------------------------------------------------
    % Test the GraphStruct property
    %--------------------------------------------------------------
    if isempty(fieldnames(obj.GraphStruct))
        warning('nb_graph_ts:graphInfoStruct:emptyGraphStruct',...
                [mfilename ':: The property ''GraphStruct'' is empty. You must set it to be able to plot.'])
        return
    end

    %--------------------------------------------------------------
    % Clear some handles of the object
    %--------------------------------------------------------------
    clearHandles(obj);

    %--------------------------------------------------------------
    % Reference to the method used
    %--------------------------------------------------------------
    obj.graphMethod = 'graphinfostruct';
        
    %--------------------------------------------------------------
    % Decide the x-ticks (types)
    %--------------------------------------------------------------
    obj.xTick        = 1:size(obj.typesToPlot,2);
    obj.typesOfGraph = obj.typesToPlot'; 

    %--------------------------------------------------------------
    % Dump all variables into local workspace. As doubles
    %--------------------------------------------------------------
    numberOfTypes = size(obj.typesToPlot,2);
    typeIndex     = ismember(obj.DB.types,obj.typesToPlot);
    for ii = 1:obj.DB.numberOfVariables
        dataTemp = nan(numberOfTypes,obj.DB.numberOfDatasets);
        for jj = 1:obj.DB.numberOfDatasets
            dataTemp(:,jj) = obj.DB.data(typeIndex,ii,jj);
        end
        eval([obj.DB.variables{ii} ' = dataTemp;'])
    end
    
    % Dump parameters into local workspace
    if ~nb_isempty(obj.parameters)
        fields = fieldnames(obj.parameters);
        for ii = 1:length(fields)
            dataTemp = obj.parameters.(fields{ii}); %#ok<NASGU>
            eval([fields{ii} ' = dataTemp;'])
        end
    end

    %--------------------------------------------------------------
    % If the 'colorOrder' or 'colors' properties are set through  
    % the set method we need to make a variables which stored this 
    % info
    %--------------------------------------------------------------
    if ~isempty(obj.colors)
        settedColorOrder          = interpretColorsProperty(obj,obj.colors,obj.DB.dataNames);
        obj.manuallySetColorOrder = true;
    elseif obj.manuallySetColorOrder    
        settedColorOrder = obj.colorOrder;  
    end
    
    %--------------------------------------------------------------
    % Get the bands given the properties of the object. only when
    % the 'fanDataset' property is given
    %--------------------------------------------------------------
    constructBands(obj);

    %==============================================================
    % Graphing starts here
    %==============================================================
    fnames             = fieldnames(obj.GraphStruct);
    obj.numberOfGraphs = length(fnames);
    for ii = 1:obj.numberOfGraphs 

        % Get the field name of the GraphStruct
        %----------------------------------------------------------
        obj.fieldName = fnames{ii};

        % Make a figure handle
        %----------------------------------------------------------
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
            
        % Need the subplotsize to adjust the font size when the 
        % fontUnits are set to normalized
        %----------------------------------------------------------
        numberColumns = round(size(obj.GraphStruct.(obj.fieldName),1)/obj.subPlotSize(1));
        numberOfPlots = size(obj.GraphStruct.(obj.fieldName),1);
        if numberOfPlots == 1
            subplotsize = [1,1];
        else
            subplotsize = [obj.subPlotSize(1),numberColumns];
        end
        
        %--------------------------------------------------------------
        % Adjust the font size if graphStyle is set to 'presentation'.
        % Will also interpret the fontScale property.
        %--------------------------------------------------------------
        oldFontSizes = adjustFontSize(obj,subplotsize);
        
        % Loop through each row of the current field (Each row 
        % represents one subplot)
        %----------------------------------------------------------
        obj.fieldIndex = 0;
        for jj = 1:numberOfPlots   %number of subplots per plot

            obj.fieldIndex = obj.fieldIndex + 1; %counter

            if ~isempty(obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1})

                %--------------------------------------------------
                % Evaluate expressions in the 'graphsStruct'
                % property
                %--------------------------------------------------
                try
                    expression      = obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1};
                    obj.dataToGraph = eval(expression);
                catch  %#ok<CTCH>
                    warning('nb_graph_ts:plotEmptyVariable',...
                            [mfilename ':: could not evaluate the expression; ' obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1} ' '...
                            'Remember that it is only possible to evaluate methods of the double class.'])

                    obj.dataToGraph = nan(length(obj.typesToPlot),1);             
                end
                numberOfVariables   = size(obj.dataToGraph,2)/obj.DB.numberOfDatasets;
                obj.variablesToPlot = {expression};

                %--------------------------------------------------
                % Get the axes of the subplot
                %--------------------------------------------------
                if numberOfPlots > 1
                    if obj.subPlotSpecial
                        obj.axesHandle = nb_subplotSpecial(obj.subPlotSize(1),numberColumns,jj,'parent',obj.figureHandle(end));   
                    else
                        obj.axesHandle = nb_subplot(obj.subPlotSize(1),numberColumns,jj,'parent',obj.figureHandle(end));                       
                    end
                    obj.axesHandle.update = 'off';
                else
                    if obj.subPlotSpecial
                        obj.axesHandle = nb_subplotSpecial(1,1,1,'parent',obj.figureHandle(end));
                    else
                    	obj.axesHandle = nb_subplot(1,1,1,'parent',obj.figureHandle(end));
                    end
                    obj.axesHandle.update = 'off';
                end
                
                %--------------------------------------------------
                % Parse optional inputs. Will be stored in the
                % property 'inputs'.
                %--------------------------------------------------
                try
                    optionalInputs = obj.GraphStruct.(obj.fieldName){obj.fieldIndex,2};
                catch  %#ok<CTCH>
                    optionalInputs = {};
                end
                parseInputs(obj,optionalInputs);

                %--------------------------------------------------
                % Set colors
                %--------------------------------------------------
                if isempty(obj.inputs.colorOrder)

                    if obj.manuallySetColorOrder   
                        obj.colorOrder = settedColorOrder;
                    else
                        obj.colorOrder = nb_plotHandle.getDefaultColors(obj.DB.numberOfDatasets*numberOfVariables);
                    end

                else
                    % Here we are setting the color order
                    % according to the optional input from the
                    % struct
                    %----------------------------------------------
                    obj.colorOrder = obj.inputs.colorOrder;
                end

                %--------------------------------------------------
                % Add base line, (default is to add it)
                %--------------------------------------------------
                addBaseLine(obj);

                %--------------------------------------------------
                % Add a horizontal line if wanted
                %--------------------------------------------------
                addHorizontalLine(obj)

                %--------------------------------------------------
                % Add vertical forecast line, if wanted
                %--------------------------------------------------
                addVerticalLine(obj);

                %--------------------------------------------------
                % Get the variable which should be added a fan
                % chart
                %--------------------------------------------------
                obj.fanVariable = obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1};

                %--------------------------------------------------
                % Add fan chart, if wanted
                %--------------------------------------------------
                addFanChart(obj);
                
                %--------------------------------------------------
                % Do the plotting
                %--------------------------------------------------
                if ~isempty(obj.inputs.plotType)
                    plotT        = obj.plotType;
                    obj.plotType = obj.inputs.plotType;
                end

                switch lower(obj.plotType)

                    case 'line'

                        % Plot the lines
                        plotLines(obj);
                        
                    case {'stacked','grouped','dec'}

                        % Create bar plot
                        barPlot(obj);

                    case 'area'

                        % Create area plot
                        areaPlot(obj); 
                        
%                     case 'combination'
% 
%                         % Here we can plot different datasets with
%                         % different plot types
%                         addPlotTypes(obj);    

                    otherwise

                        error([mfilename,':: plot type ' obj.inputs.plotType ' is not supported by this method :: (graphInfoStruct)'])

                end
                
                if ~isempty(obj.inputs.plotType)
                    obj.plotType = plotT;
                end

                %--------------------------------------------------
                % Add ticks and make sure that the axes look nice
                %--------------------------------------------------
                setAxes(obj)

                %--------------------------------------------------
                % Add a title to the plot
                %--------------------------------------------------
                addTitle(obj); 

                %--------------------------------------------------
                % Add the x-label
                %--------------------------------------------------
                addXLabel(obj);

                %--------------------------------------------------
                % Add the y-label
                %--------------------------------------------------
                addYLabel(obj)
                
                %--------------------------------------------------
                % Add legend to subplot if wanted
                %--------------------------------------------------
                if ~isempty(obj.inputs.legends) && jj ~= numberOfPlots
                    addLegend(obj);
                end
                
            end

        end
        %====End graphing==========================================

        %----------------------------------------------------------
        % Decide the legends
        %----------------------------------------------------------
        addLegend(obj);

        %----------------------------------------------------------
        % Add figure title to subplot if wanted
        %----------------------------------------------------------
        addFigureTitle(obj);
        
        %----------------------------------------------------------
        % Save it down the figure
        %----------------------------------------------------------
        if ~isempty(obj.saveName)
            saveFigure(obj,int2str(ii));
        end 
        
        %--------------------------------------------------------------
        % Revert the font sizes
        %--------------------------------------------------------------
        revertFontSize(obj,oldFontSizes);

    end

end
