function graph(obj)
% Syntax:
% 
% graph(obj)
% 
% Description:
% 
% Create a graph or more graphs
% 
% Graphs all the objects given to the nb_graph_subplot object.
% 
% Input:
% 
% - obj : An object of class nb_graph_subplot
% 
% Output:
%
% The graph(s) plotted on the screen.
%
% Examples:
% 
% obj.graph();
%
% See also:
% nb_graph_subplot
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %--------------------------------------------------------------
    % If the 'graphObjects' property is empty there is nothing to 
    % graph
    %--------------------------------------------------------------
    if isempty(obj.graphObjects)
        return;
    end

    %--------------------------------------------------------------
    % Clear some handles of the object
    %--------------------------------------------------------------
    clearHandles(obj);

    %--------------------------------------------------------------
    % Find out how many figures we are going to plot
    %--------------------------------------------------------------
    numberOfSubplots   = obj.subPlotSize(1)*obj.subPlotSize(2);
    numberOfObjects    = size(obj.graphObjects,2);
    obj.numberOfGraphs = ceil(numberOfObjects/numberOfSubplots);
    
    %--------------------------------------------------------------
    % Start the plotting
    %--------------------------------------------------------------
    if obj.manuallySetFigureHandle == 0
        if ~isempty(obj.plotAspectRatio)
            s(1,obj.numberOfGraphs) = nb_graphPanel(obj.plotAspectRatio);
        else
            s(1,obj.numberOfGraphs) = nb_figure;
        end
        obj.figureHandle = s;
    end

    objectIndex = 1;
    for ii = 1:obj.numberOfGraphs
    
        %---------------------------------------------------------- 
        % Set the figure properties
        %----------------------------------------------------------
        if obj.manuallySetFigureHandle == 0
            set(obj.figureHandle(ii),'color',[1, 1, 1],'units','characters');
            if ~isempty(obj.figurePosition)
                set(obj.figureHandle(ii),'color',[1, 1, 1],'units','characters','position',obj.figurePosition);
            end
        end
        
        %----------------------------------------------------------
        % Graph the given nb_graph objects
        %----------------------------------------------------------
        if numberOfObjects - objectIndex + 1 >= numberOfSubplots
            number = numberOfSubplots;
        else
            number = numberOfObjects - objectIndex + 1;
        end
        
        for jj = 1:number
            
            plotter = obj.graphObjects{objectIndex};
            if isa(plotter,'nb_graph_adv')
                plotter = convertTitlesAndFooter(plotter,obj.language);
            end
            
            if plotter.DB.numberOfDatasets > 1
                giveErr = true;
                if isprop(plotter,'page')
                    if ~isempty(plotter.page)
                        giveErr = false;
                    end
                end
                if giveErr 
                    error([mfilename ':: The provided nb_graph_obj object cannot have data with more then one page.'])
                end
            end
            
            % Need to give the figure handle to the nb_graph object 
            % to be plotted in the figure 
            %------------------------------------------------------
            setSpecial(plotter,'figureHandle',obj.figureHandle(ii));
            
            % Need to set some properties of the nb_graph object.
            % (Some are not set as default, i.e. just use the
            % property values of the given nb_graph object)
            %------------------------------------------------------   
            plotter.language = obj.language;
            plotter.saveName = '';
            if isa(plotter,'nb_graph')
                plotter.shading            = obj.shading; 
                plotter.axesScaleLineWidth = obj.axesScaleLineWidth;
            end 
            
            % Find and set the position of the nb_graph object in 
            % the current figure
            %------------------------------------------------------
            if ~obj.manualAxesPosition
                
                position = nb_subplot_position(obj.subPlotSize(1),obj.subPlotSize(2),jj);

                % Correct the position if the property subPlotSpecial
                % is set to 1
                if obj.subPlotSpecial

                    if obj.subPlotSize(1) == 2 && obj.subPlotSize(2) == 1
                        position(1) = 0.3;
                        position(3) = 0.4;
                    elseif obj.subPlotSize(1) == 1 && obj.subPlotSize(2) == 2
                        position(2) = 0.3;
                        position(4) = 0.4;
                    end

                end
                plotter.position  = position;
                
            end
            plotter.fontScale = obj.scale;
            
            % Graph the nb_graph object in the current figure
            %------------------------------------------------------
            graph(plotter);
            plotter.tag = objectIndex;
            objectIndex = objectIndex + 1;
            
            ax = get(plotter,'axesHandle');
            obj.axesHandles = [obj.axesHandles,ax];
            
        end
        
        %----------------------------------------------------------
        % Save figure down to the wanted file format
        %----------------------------------------------------------
        if ~isempty(obj.saveName)
            obj.saveFigure(int2str(ii));
        end
         
    end

end

function plotter = convertTitlesAndFooter(object,language)

    plotter = object.plotter; % Get the underlying graph object
    clean(plotter);
    
    % Title
    if strcmpi(language,'english') || strcmpi(language,'engelsk')
        plotter.title = object.figureTitleEng;
    else
        plotter.title = object.figureTitleNor;
    end
    plotter.titleFontSize    = object.figureTitleFontSize;
    plotter.titleAlignment   = object.figureTitleAlignment;
    plotter.titlePlacement   = object.figureTitlePlacement;
    plotter.titleInterpreter = object.figureTitleInterpreter;
    plotter.titleFontWeight  = object.figureTitleFontWeight;
    
    % Footer
    if strcmpi(language,'english') || strcmpi(language,'engelsk')
        plotter.xLabel = object.footerEng;
    else
        plotter.xLabel = object.footerNor;
    end
    plotter.xLabelFontSize    = object.footerFontSize;
    plotter.xLabelAlignment   = object.footerAlignment;
    plotter.xLabelPlacement   = object.footerPlacement;
    plotter.xLabelInterpreter = object.footerInterpreter;
    plotter.xLabelFontWeight  = object.footerFontWeight;

end
