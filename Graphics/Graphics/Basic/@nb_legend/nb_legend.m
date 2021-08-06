classdef nb_legend < nb_annotation & nb_movableAnnotation
% Syntax:
%     
% obj = nb_legend(parent,legends,varargin)
% 
% Superclasses:
% 
% handle, nb_annotation, nb_movableAnnotation
%     
% Description:
%     
% This is a class for making legend of plots
% 
% I strongly recommend to use this class instead of the MATLAB 
% legend command if you use the nb_* plot functions.
%     
% Caution : - When the type property of this class is set to 
%             'matlab', the lineStyle '---', will be given as '-'.
%     
%           - When the 'type' property of this class is set to 'nb'
%             it is not possible to move the legend by click and 
%             drag, as the normal MATLAB legend.
%     
%           - If you create more legends of a plot the first 
%             legends will not longer be moveable. (Even if the 
%             type property is set to 'MATLAB')
%     
% Constructor:
%     
%     obj = nb_legend(parent,legends,varargin)
%     
%     Input:
% 
%     - parent   : A nb_axes handle
% 
%     - legends  : A cellstr of the legends of the plot. Say you 
%                  do not want to plot the legend of a plotted 
%                  variable you can type '' at its location in the 
%                  cellstr, and it will not be shown in the legend.
% 
%     - varargin : ...,'propertyName',propertyValue,...
%    
%     Output:
% 
%     - obj : An object of class nb_legend (handle)
%     
%     Examples:
% 
%     nb_legend(ax,legends)
%     nb_legend(ax,legend,'propertyName',propertyValue,...)
%     leg = nb_legend(ax,legend,'propertyName',propertyValue,...)
%     
% See also:
% legend
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % If you want a box around the legend or not. 'on' | 'off'. 
        % 'on' is default. If you set it to 'off' the movability
        % of the legend is destroyed
        box             = 'on'; 
        
        % Backgraound color. Either a string with the color name or
        % a 1x3 double with the RGB colors. Default is 'none'.
        color           = 'none';               
        
        % Number of columns of the legend.
        columns         = 1;                    
        
        % Fake legends added to the legend. Must be given as
        % nb_legendDetails vector with size 1xM.
        fakeLegends     = [];   
        
        % Sets the font color(s) of the legend text.
        % Must either be a 1x3 double or a string with 
        % the color name of all legend text objects, or
        % a M x 3 double or a cellstr array with size
        % 1 x M with color names to use of each legend
        % text object.
        fontColor       = [0,0,0];
        
        % The font name used for the text of the legend. As a string.
        fontName        = 'Arial';      
        
        % Font size of the text in the legend. As a scalar.
        fontSize        = 10;                   
        
        % {'points'} | 'normalized' | 'inches' |  
        % 'centimeters' | 'pixels'
        % 
        % Font size units. MATLAB uses this property to 
        % determine the units used by the fontSize 
        % property.
        % 
        % normalized - Interpret FontSize as a fraction 
        % of the height of the parent axes. When you 
        % resize the axes, MATLAB modifies the screen 
        % fontSize accordingly.
        % 
        % pixels, inches, centimeters, and points: 
        % Absolute units. 1 point = 1/72 inch.
        fontUnits       = 'points';
        
        % Font weight of the text in the legend. As a string.
        fontWeight      = 'normal';             
        
        % Sets the column width of the legend (Only when dealing 
        % with more then one column). If empty they are try to 
        % adjust to the text.
        columnWidth     = [];  
        
        % {'none'} | 'tex' | 'latex' . See the text properties for 
        % more.
        interpreter     = 'none'                
        
        % The legends of the plot. Given as a cellstr. Say you 
        % don't want to plot the legend of a plotted variable
        % you can type '' at its location in the cellstr, and it 
        % will not be shown in the legend.
        legends         = {}; 
        
        % The location of the legend;  'west' | {'northwest'} |
        % 'north' |'northeast' | 'east' | 'southeast' | 'south'
        % | 'southwest' | 'center'  | 'below' | 'middle' | 'outsideright'
        % | 'outsiderighttop'. When adding a legend to a nb_pie plot the
        % 'pie' option could also be used.
        location        = 'northwest';        
        
        % Indicate if the font when fontUnits is set to 'normalized'
        % should be normalized to the axes ('axes') or to the
        % figure ('figure'), i.e. the default axes position 
        % [0.1 0.1 0.8 0.8].
        normalized      = 'figure';
        
        % Set the object to notify. Must contain the property
        % legPosition. Default is []. Depricated property!
        objectToNotify  = [];
         
        % Set the position of the legend 1x2 double. I.e; 
        % [xLeftPosition,yLowerPosition]. Only an option when the 
        % type property is set to 'nb'.
        position        = [];                   
        
        % Set this property to reoder the legend. Either
        % a string with {'default'} | 'inverse' or a 
        % double with how to reorder the legend. E.g. if  
        % you have 3 legends to plot the default index  
        % will be [1,2,3], the inverse ('inv') will be 
        % [3,2,1]. If you want to decide that the 3. 
        % legend should be first, then the 1. and 2., you
        % can type in [3,1,2].
        %
        %  Caution : If a double is given it must have as
        %            many elements as there is plotted
        %            legends. I.e. if you give a empty 
        %            string to one of the legends it will  
        %            be excluded. Say you provide the 
        %            property legends as {'s','','t','f'}
        %            then the double must have size 1x3.
        reorder         = 'default';
        
        % Vertical space between the text in the legend. Must be 
        % scalar. Default is
        space           = 0;  
                  
        % Sets the visibility of the legend. {'on'} | 'off'.
        visible         = 'on';                 
        
    end
    
    properties(SetAccess=protected)
        
        % position rectangle (read-only)
        % 
        % Position and size of the legend. A four-element vector  
        % that defines the size and position of the legend:
        % 
        % [left,bottom,width,height]
        % 
        % left and bottom are the x- and y-coordinates of the lower  
        % left corner of the text extent. The units are normalized.
        extent              = [];
        
        % Indicator if fast legend is tried to be used. If true moving 
        % the legend is not possible.
        fast                = false;
        
    end
    
    properties(Access=public,Hidden=true)
        legTightInsetY         = [];
        heightOfText           = []; 
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        legendDetails          = [];
        listener               = [];
        plotHandle             = [];
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
        function obj = nb_legend(parent,legends,varargin)
            
            if nargin == 0
                return
            end
            
            if ~isa(parent,'nb_axes') && ~isempty(parent)
                error([mfilename ':: The first input tp the nb_legend constructor must be an object of class nb_axes or it must be empty.'])
            end
            
            if size(legends,1) > 1 && size(legends,2) == 1
                legends = legends';
            end
            
            % Assign property legends
            obj.legends = legends;
            obj.parent  = parent;
            
            if nargin > 3 
                % Set the properties of the object
                obj.set(varargin{:});
            else
                if isempty(obj.parent)
                    obj.parent = nb_axes();
                end
                
                % Add the legend to the nb_axes object, where it
                % will be plotted.
                %--------------------------------------------------
                obj.parent.addLegend(obj);
            end
            
        end
        
        varargout = get(varargin)
        
        function set.box(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The box property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.box = value;
        end
        
        function set.color(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename '::  The color property must be '...
                    'set to a valid color property.'])
            end
            obj.color = value;
        end
        
        function set.columns(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename '::  The columns property must be '...
                    'given as a scalar double.'])
            end
            obj.columns = value;
        end
        
        function set.fakeLegends(obj,value)
            if ~isa(value,'nb_legendDetails') && ~isempty(value)
                error([mfilename '::  The fakeLegends property must be '...
                    'given as a nb_legendDetails vector.'])
            end
            obj.fakeLegends = value;
        end
        
        function set.fontColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename '::  The fontColor property must be '...
                    'set to a valid color property.'])
            end
            obj.fontColor = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename '::  The fontName property must be '...
                    'given as a one line character array.'])
            end
            obj.fontName = value;
        end
        
        function set.fontSize(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename '::  The fontSize property must'...
                    ' be a scalar.'])
            end
            obj.fontSize = value;
        end
        
        function set.fontUnits(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'points',...
                    'normalized'...
                    'inches','centimeters','pixels'},value))
                error([mfilename ':: The fontUnits property must be'...
                    ' set to either ''points'', ''normalized'''...
                    ' ''inches'', ''centimeters'' or ''pixels''.'])
            end
            obj.fontUnits = value;
        end
        
        function set.fontWeight(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontWeight property must be given'...
                    ' as a one line character array.'])
            end
            obj.fontWeight = value;
        end
        
        function set.columnWidth(obj,value)
            if ~nb_isScalarNumber(value) && ~isempty(value)
                error([mfilename '::  The columnWidth property must'...
                    ' be a scalar or empty.'])
            end
            obj.columnWidth = value;
        end
        
        function set.interpreter(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'tex','none'},...
                    value))
                error([mfilename ':: The interpreter property must be'...
                    ' set to either ''tex'' (default) or ',...
                    ' ''none''.'])
            end
            obj.interpreter = value;
        end
        
        function set.location(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename '::  The location property must be '...
                    'given as a one line character array.'])
            end
            obj.location = value;
        end
        
        function set.legends(obj,value)
            if ~iscellstr(value) && ~isempty(value)
                error([mfilename '::  The legends property must'...
                    ' be given as a cellstring.'])
            end
            obj.legends = value;
        end
        
        function set.normalized(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The normalized property must be'...
                    ' set to a one line character array.'])
            end
            obj.normalized = value;
        end
        
        function set.objectToNotify(obj,value)
            if ~isa(value,'double') && ~isempty(value) && ~ischar(value)
                error([mfilename ':: The objectToNotify property must be'...
                    ' set to a one line character array.'])
            end
            obj.objectToNotify = value;
        end
        
        function set.reorder(obj,value)
            if ~nb_isOneLineChar(value) && ~isa(value,'double')
                error([mfilename ':: The reorder property must be given as'...
                    ' a one line character array or double.'])
            end
            obj.reorder = value;
        end
        
        function set.space(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The space property must be given as'...
                    ' a scalar double.'])
            end
            obj.space = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The visible property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
        
        %{
        ---------------------------------------------------------------
        Delete the object
        ---------------------------------------------------------------
        %}
        function delete(obj)
            
            % Remove it form its parent
            if isa(obj.parent,'nb_axes')
                if isvalid(obj.parent)
                    obj.parent.removeLegend(obj);
                end
            end
            
            if ~isempty(obj.listeners)
                if isvalid(obj.listeners)
                    delete(obj.listeners);
                end
                obj.listeners = [];
            end
            
            if strcmpi(obj.deleteOption,'all')
                
                for ii = 1:size(obj.children,1)
                    if isa(obj.children{ii},'nb_patch')
                        if isvalid(obj.children{ii})
                            delete(obj.children{ii})
                        end
                    else
                        if ishandle(obj.children{ii})
                            delete(obj.children{ii})
                        end
                    end
                end
                
                if ~isempty(obj.plotHandle)
                    if ishandle(obj.plotHandle)
                        if ~isempty(obj.listeners)
                            if isvalid(obj.listeners)
                                delete(obj.listeners);
                            end
                        end
                    end
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the legend
        -------------------------------------------------------------------
        %}
        function update(obj)
            plotLegend(obj)
        end
        
        function deleteChildren(obj)
            
            if ~isempty(obj.plotHandle)
                delete(obj.plotHandle);
                obj.plotHandle = [];
            end
            obj.children = [];
            if ~isempty(obj.listeners)
                delete(obj.listeners);
                obj.listeners = [];
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods of the class
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Add the legend given the settings. 
        
        Caution : If you reset the properties using the set function, this
                  function is called.
        -------------------------------------------------------------------
        %}
        function plotLegend(obj)
            
            if isempty(obj.legends)
                obj.extent = [];
                return
            end
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            deleteChildren(obj);
            
            %------------------------------------------------------
            % Get the legend information
            %------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                getLegendInformation(obj);
            else
                error([mfilename ':: The input ''parent'' must be a nb_axes handle (object).'])
            end
            
            % Check properties
            %--------------------------------------------------------------
            % Ensure that the 'legend' property is a cellstr 
            if ~iscellstr(obj.legends)
                if ischar(obj.legends)
                    obj.legends = cellstr(obj.legends);
                else
                    error([mfilename ':: The ''legend'' property must either be a string or a cellstr. Is ' class(obj.legends)])
                end
            end
            
            if ~ishandle(obj.parent.plotAxesHandle)
                return
            end
            
            % Reorder the nb_legendDetails objects and legend text array. 
            % It also remove unwanted legends (The legends with empty
            % strings)
            %--------------------------------------------------------------
            [obj,legs]  = interpretLegends(obj);
            
            % Plot the legend
            %--------------------------------------------------------------
            addGridLegend(obj,legs);
            
            % Add listener to the current position of the mouse.
            %-------------------------------------------------------------
            if isa(obj.parent.parent,'nb_figure')
                obj.listeners = [obj.listeners,...
                                 addlistener(obj.parent.parent,'mouseMove',@obj.mouseMoveCallback), ...
                                 addlistener(obj.parent.parent,'mouseDown',@obj.mouseDownCallback), ...
                                 addlistener(obj.parent.parent,'mouseUp',  @obj.mouseUpCallback),...
                                 addlistener(obj.parent.parent,'resized',  @(src,event)obj.onFigureResize())];
            end
            
        end
 
        %------------------------------------------------------------------
        function obj = addGridLegendFast(obj,legs)
        % Mine is faster due to time spent in find_legend_info inside 
        % legend...
            
            % Make an invisible axes to plot all the series of the legend
            if isa(obj.parent.parent,'nb_graphPanel')
                par = obj.parent.parent.panelHandle;
            else
                par = obj.parent.parent.figureHandle;
            end
            obj.plotHandle = axes('visible','off','parent',par,'yLim',[0,1],...
                'xLim',[0,1],'position',get(obj.parent.plotAxesHandle,'position'));
            
            % Plot each element included in the legend
            for ii = 1:size(obj.legendDetails,2)
                plotOneElement(obj,obj.legendDetails(ii));
            end
            
            % Get legend text color
            if size(obj.fontColor,1) == 1
                fColor = obj.fontColor;
            else
                fColor = [0,0,0];
            end
            
            % If the font size is normalized we get the font size
            % transformed to another units
            [~,fontS] = getFontSize(obj);
            
            % Make the legends
            [obj.children,~,~,txt] = legend(obj.plotHandle,legs,...
                'color',        obj.color,...
                'box',          obj.box,...
                'numColumns',   obj.columns,...
                'textColor',    fColor,...
                'fontName',     obj.fontName,...
                'fontSize',     fontS,...
                'fontWeight',   obj.fontWeight,...
                'interpreter',  obj.interpreter,...
                'location',     obj.location,...
                'visible',      obj.visible);
            
            if size(obj.fontColor,1) > 1
                for ii = 1:length(legs)
                    set(txt(ii),'color',fColor(ii,:));
                end
            end
            
        end
        
        function plotOneElement(obj,legDetails)
            
            handles = {};
            switch legDetails.type
                
                case 'line'
                          
                    if strcmpi(legDetails.lineMarkerFaceColor,'auto')
                        markerFaceColor = legDetails.lineColor;
                    else
                        markerFaceColor = legDetails.lineMarkerFaceColor;
                    end
                    
                    h = line([0,1],[0,1],...
                             'clipping',        'off',...
                             'lineWidth',       legDetails.lineWidth,...
                             'lineStyle',       legDetails.lineStyle,...
                             'color',           legDetails.lineColor,...
                             'marker',          legDetails.lineMarker,...
                             'markerSize',      legDetails.lineMarkerSize,...
                             'markerEdgeColor', legDetails.lineMarkerEdgeColor,...
                             'markerFaceColor', markerFaceColor,...
                             'parent',          obj.plotHandle,...
                             'visible',         'off');
                    handles = [handles, {h}];   %#ok<NASGU>
                    
                case 'patch'
                    
                    if strcmpi(legDetails.patchEdgeColor,'same')
                        edgeColor = legDetails.patchColor(1,:);
                    else
                        edgeColor = legDetails.patchEdgeColor;
                    end
                    
                    h = patch([0,1],[0,1],legDetails.patchColor,...
                                 'clipping',        'off',...
                                 'edgeColor',       edgeColor,...
                                 'faceAlpha',       legDetails.patchFaceAlpha,...
                                 'faceLighting',    legDetails.patchFaceLighting,...
                                 'lineStyle',       legDetails.patchEdgeLineStyle,...
                                 'lineWidth',       legDetails.patchEdgeLineWidth,...
                                 'parent',          obj.plotHandle,...
                                 'visible',         leg.visible);       
                    handles = [handles, {h}];           %#ok<NASGU>
                    
                otherwise
                    error([mfilename ':: Only ''line'' and ''path'' are supported types of this class.'])
            end
            
        end
        
        %------------------------------------------------------------------
        function obj = addGridLegend(obj,legs)
           
            % Find out how many legend we are going to plot (It  
            % could be the case that there has been given more 
            % legends then plotted variables)
            %------------------------------------------------------
            totSize = size(obj.legendDetails,2);
            
            % Set the font colors of the plotted legends
            %------------------------------------------------------
            obj = interpretFontColor(obj);
            
            % If we are dealing with the 'below' or 'middle' 
            % location we will have a horizontally oriented legend
            %------------------------------------------------------
            if strcmpi(obj.location,'below') || strcmpi(obj.location,'middle')                  
                obj.columns = totSize;
            end
                  
            % Work out how many traces per column in the new format.
            %------------------------------------------------------
            numlines     = totSize;
            numpercolumn = ceil(numlines/obj.columns);
            
            % Settings for the legend
            %------------------------------------------------------
            axesOldPositions = obj.parent.position;
            axesPositions    = obj.parent.getOriginalPosition();
            scaleY           = axesOldPositions(4)/axesPositions(4);
            scaleX           = axesOldPositions(3)/axesPositions(3);
            if totSize == 0
                obj.extent = [axesPositions(1),axesPositions(2),0 ,0];
                return
            end
            
            defaultPosX   = .475;
            defaultPosY   = .5;
            xScale        = defaultPosX;%/axesPositions(3);
            yScale        = defaultPosY;%/axesPositions(4);
            lineLength    = 0.125*xScale;
            legYSpacer    = 0.05*yScale;
            legXSpacer    = 0.01*xScale;
            textSpacer    = 0.008*xScale;
            colSpacer     = 0.015*xScale;
            
            % If the font size is normalized we get the font size
            % transformed to another units
            %------------------------------------------------------
            [fontU,fontS]   = getFontSize(obj);
            numRowsOfLegend = nan(numpercolumn,obj.columns);
            try
            
                % Get the width of each of the columns in the parent
                % axes coordinates
                %------------------------------------------------------
                hightOfText = zeros(numpercolumn,1);
                if isempty(obj.columnWidth)

                    % By plotting all the legends as text object I can 
                    % find out the width and hight of the columns of 
                    % the legend
                    widthOfColumns = zeros(1,obj.columns);
                    colInd         = 1; % Column index
                    rowInd         = 1;
                    for ii = 1:size(legs,2)

                        if colInd > obj.columns
                            colInd = 1;
                        end
                        if rowInd > numpercolumn
                            rowInd = 1;
                        end

                        t = text(0,0,legs{ii},...
                                 'fontName',            obj.fontName,...
                                 'fontUnits',           fontU,...
                                 'fontSize',            fontS,...
                                 'fontWeight',          obj.fontWeight,...
                                 'horizontalAlignment', 'left',...
                                 'interpreter',         obj.interpreter,...
                                 'parent',              obj.parent.plotAxesHandle,...
                                 'visible',             'off');

                        set(t,'units','normalized');
                        drawnow;
                        extent1 = get(t,'extent');
                        delete(t);
                        if extent1(3) > widthOfColumns(colInd)
                            widthOfColumns(colInd) = extent1(3);
                        end
                        
                        if extent1(4) > hightOfText(rowInd)
                            hightOfText(rowInd) = extent1(4)*scaleY;
                        end
                        numRowsOfLegend(rowInd,colInd) = size(legs{ii},1);

                        rowInd = rowInd + 1;
                        colInd = colInd + 1;

                    end
                    widthOfColumns = widthOfColumns*scaleX + lineLength + textSpacer + colSpacer;

                else

                    % Need to find the hight of the text
                    colInd = 1; 
                    rowInd = 1;
                    for ii = 1:size(legs,2)

                        if colInd > obj.columns
                            colInd = 1;
                        end
                        if rowInd > numpercolumn
                            rowInd = 1;
                        end

                        t = text(0,0,legs{ii},...
                                 'fontName',            obj.fontName,...
                                 'fontUnits',           fontU,...
                                 'fontSize',            fontS,...
                                 'fontWeight',          obj.fontWeight,...
                                 'horizontalAlignment', 'left',...
                                 'interpreter',         obj.interpreter,...
                                 'parent',              obj.parent.plotAxesHandle,...
                                 'visible',             'off');

                        set(t,'units','normalized');
                        drawnow;
                        extent1 = get(t,'extent');
                        delete(t);
                        
                        if extent1(4) > hightOfText(rowInd)
                            hightOfText(rowInd) = extent1(4)*scaleY;
                        end
                        numRowsOfLegend(rowInd,colInd) = size(legs{ii},1);

                        rowInd = rowInd + 1;
                        colInd = colInd + 1;

                    end

                    % Test the columnWidth property
                    if isscalar(obj.columnWidth)
                        widthOfColumns = repmat(obj.columnWidth,1,obj.columns);
                    elseif size(obj.columnWidth,1) == 1 && size(obj.columnWidth,2) == obj.columns
                        widthOfColumns = obj.columnWidth;
                    else
                       error([mfilename ':: The columnWidth property must either be a scalar with the width of all the legend columns, '...
                                        'or a 1 x columns double vector of the width of the individual columns. Is '...
                                        int2str(size(obj.columnWidth,1)) 'x' int2str(size(obj.columnWidth,2)) ', but must be 1x'...
                                        int2str(obj.columns)]) 
                    end

                end
                
            catch %#ok<CTCH>
                error([mfilename ':: The axes has been closed. Cannot add legend to a closed nb_axes handle.'])   
            end
            
            % Find the factor to rescale from axes units to
            % figure units
            %------------------------------------------------------
            xFigPos   = axesPositions(1);
            xFigScale = axesPositions(3);
            yFigPos   = axesPositions(2);
            yFigScale = axesPositions(4);
            
            % If we now have that the parent of the nb_axes is an
            % nb_graphPanel object we need to convert from panel
            % units to figure units
            %------------------------------------------------------
            if isa(obj.parent.parent,'nb_graphPanel') && verLessThan('matlab','8.4')
                posPanel  = nb_getInUnits(obj.parent.parent.panelHandle,'position','normalized');
                xFigScale = xFigScale*posPanel(3);
                yFigScale = yFigScale*posPanel(4);               
            end
            
            % Rescale the line length to figure (panel) units
            %------------------------------------------------------
            lineLength = lineLength*xFigScale;
            
            % Scale the width and height of columns to figure units 
            % instead of axes units
            %------------------------------------------------------
            widthOfColumns = widthOfColumns*xFigScale;
            totLength      = sum(widthOfColumns,2);
            textSpacer     = textSpacer*xFigScale;
            hightOfText    = hightOfText*yFigScale;
            rowSpacer      = hightOfText + obj.space*xScale*yFigScale;
            
            % Find the location of the legend, if not the position 
            % property is set. (Figure (panel) units from the
            % bottom left corner of the axes)
            %------------------------------------------------------
            if ~isa(obj.parent.parent,'nb_figure')
                if strcmpi(obj.location,'below') || strcmpi(obj.location,'middle')
                    obj.location = 'best';
                end
            end
            specialLocation = 0;
            if isempty(obj.position)
            
                switch lower(obj.location)

                    case 'below'
                        
                        xLocation = 0;
                        yLocation = 0;
                        specialLocation = 1;
                    
                    case 'best'

                        %warning('nb_legend:NoLocationBestForTypeNB','No location ''Best'' for the class nb_legend. Sets it to ''NorthWest''.')

                        xLocation = [legXSpacer, legXSpacer + lineLength];
                        yLocation = [axesPositions(4) -  legYSpacer , axesPositions(4) -  legYSpacer];

                    case 'middle'
                           
                        xLocation = 0;
                        yLocation = 0;
                        specialLocation = 1;
                         
                    case 'north'

                        xLocation = [axesPositions(3)/2 - totLength/2, axesPositions(3)/2 + lineLength - totLength/2];
                        yLocation = [axesPositions(4) -  legYSpacer , axesPositions(4) -  legYSpacer];

                    case 'south'

                        xLocation = [axesPositions(3)/2 - totLength/2, axesPositions(3)/2 + lineLength - totLength/2];
                        yLocation = [sum(rowSpacer) + legYSpacer, sum(rowSpacer) + legYSpacer];

                    case 'east'

                        middle    = ceil(size(rowSpacer,1)/2);
                        extra     = rowSpacer(middle)/2;
                        xLocation = [axesPositions(3) - totLength, axesPositions(3) - totLength + lineLength];
                        yLocation = [axesPositions(4)/2 + sum(rowSpacer)/2 - extra, axesPositions(4)/2 + sum(rowSpacer)/2 - extra];

                    case 'west'

                        middle    = ceil(size(rowSpacer,1)/2);
                        extra     = rowSpacer(middle)/2;
                        xLocation = [legXSpacer, legXSpacer + lineLength];
                        yLocation = [axesPositions(4)/2 + sum(rowSpacer)/2 - extra, axesPositions(4)/2 + sum(rowSpacer)/2 - extra];

                    case 'northwest'

                        xLocation = [legXSpacer, legXSpacer + lineLength];
                        yLocation = [axesPositions(4) - legYSpacer , axesPositions(4) - legYSpacer];

                    case 'northeast'

                        xLocation = [axesPositions(3) - totLength, axesPositions(3) - totLength + lineLength];
                        yLocation = [axesPositions(4) - legYSpacer , axesPositions(4) - legYSpacer];

                    case 'southwest'

                        xLocation = [legXSpacer, legXSpacer + lineLength];
                        yLocation = [sum(rowSpacer) + legYSpacer, sum(rowSpacer) + legYSpacer];

                    case 'southeast'

                        xLocation = [axesPositions(3) - totLength, axesPositions(3) - totLength + lineLength];
                        yLocation = [sum(rowSpacer) + legYSpacer, sum(rowSpacer) + legYSpacer];

                    case 'center'

                        middle    = ceil(size(rowSpacer,1)/2);
                        extra     = rowSpacer(middle)/2;
                        xLocation = [axesPositions(3)/2 - totLength/2, axesPositions(3)/2 + lineLength - totLength/2];
                        yLocation = [axesPositions(4)/2 + sum(rowSpacer)/2 - extra, axesPositions(4)/2 + sum(rowSpacer)/2 - extra];

                    case 'pie'

                        middle    = ceil(size(rowSpacer,1)/2);
                        extra     = rowSpacer(middle)/2;
                        pieSpacer = 0.55;
                        xLocation = [pieSpacer, pieSpacer + lineLength];
                        yLocation = [axesPositions(4)/2 + sum(rowSpacer)/2 - extra, axesPositions(4)/2 + sum(rowSpacer)/2 - extra];

                    case 'outsiderighttop'    
                        
                        % Placed outside
                        rightMost = getRightMostOriginal(obj.parent);
                        xLocation = [rightMost - totLength - 0.01*xFigScale - lineLength, rightMost - totLength - 0.01*xFigScale];
                        
                        % Centered along y-axis
                        yLocation = axesPositions(4) - legYSpacer;
                        yLocation = yLocation(1,ones(1,2));
                           
                        % Correct for adding start point later
                        xLocation = xLocation - xFigPos;
                        
                    case 'outsideright'
                        
                        % Placed outside
                        rightMost = getRightMostOriginal(obj.parent);
                        xLocation = [rightMost - totLength - 0.01*xFigScale, rightMost - totLength + lineLength - 0.01*xFigScale];
                        
                        % Centered along y-axis
                        middle    = ceil(size(rowSpacer,1)/2);
                        extra     = rowSpacer(middle)/2;
                        yLocation = axesPositions(4)/2 + sum(rowSpacer)/2 - extra;
                        yLocation = yLocation(1,ones(1,2));
                           
                        % Correct for adding start point later
                        xLocation = xLocation - xFigPos;
                        
                    otherwise
                        error([mfilename ':: No legend placement ' obj.location])
                end
                
            else
                % The top left position of the legend
                xLocation = obj.position(1)*axesPositions(3);
                yLocation = obj.position(2)*axesPositions(4);
                xLocation = [xLocation, xLocation + lineLength];
                yLocation = ones(1,2)*yLocation;%+ hightOfText/2
            end
           
            % Find the xLocation and yLocation positions in
            % figure (panel) units instead of figure units
            % from the bottom left corner of the axes
            %------------------------------------------------------
            xLocation = xLocation + xFigPos;
            yLocation = yLocation + yFigPos;
            
            if specialLocation
                
                % Calculate the positions in figure (panel) units 
                % directly
                totLength = sum(widthOfColumns,2);
                switch lower(obj.location)

                    case 'below'
                            
                        halfLength = totLength/2;
                        xLocation  = [0.5 - halfLength, 0.5 - halfLength + lineLength];
                        
                        % Get the lowest point of all the nb_axes 
                        % objects. 
                        currentFigure = obj.parent.parent;
                        lastAxes      = currentFigure.children(end);
                        lowest        = getYLow(lastAxes,2);
                        yLocation     = [lowest - hightOfText/2,lowest - hightOfText/2];
                            
                    case 'middle'
                        
                        halfLength    = totLength/2;
                        xLocation     = [0.5 - halfLength, 0.5 - halfLength + lineLength];
                        
                        % Here I need to find the lowest point of 
                        % the first axes plotted in the current
                        % figure
                        currentFigure = obj.parent.parent;
                        firstAxes     = currentFigure.children(1);
                        lowest        = getYLow(firstAxes,2);
                        yLocation     = [lowest - hightOfText/2,lowest - hightOfText/2];
                            
                end
                
            end
            
            % Find the start position of each column in figure 
            % units
            %------------------------------------------------------
            legTightInsetX     = 0.01*xFigScale;
            legTightInsetYTemp = 0.01*yFigScale;
            startOfColumns     = cumsum(widthOfColumns) + legTightInsetX;
            startOfColumns     = [legTightInsetX,startOfColumns(1,1:end-1)];
            
            % Get the positions of all the legends in the new 
            % legend (figure units)
            %--------------------------------------------------------------
            colInd   = 1; % Column index
            rowInd   = 1; % Row index
            totInd   = 1; % Total index
            xdata    = cell(totSize,1);
            ydata    = cell(totSize,1);
            ySpace   = cumsum([0;rowSpacer]);
            for ii = 1:totSize
                
                if colInd > obj.columns
                    rowInd = rowInd + 1;
                    colInd = 1;
                end
                xdata{totInd} = [xLocation(1) + startOfColumns(colInd), xLocation(2) + startOfColumns(colInd)];
                if colInd == 1
                    ydata{totInd} = [yLocation(1) - ySpace(rowInd), yLocation(2) - ySpace(rowInd)];
                else
                    ydata{totInd} = ydata{totInd - 1};
                end
                colInd = colInd + 1;
                totInd = totInd + 1;
                
            end
            
            % Get the extent of the legend
            %------------------------------------------------------
            extentTemp         = nan(1,4);
            extentTemp(1)      = xdata{1}(1) - legTightInsetX;
            extentTemp(2)      = ydata{end}(1) - hightOfText(end)/2 - legTightInsetYTemp;
            extentTemp(3)      = totLength + 2*legTightInsetX;
            extentTemp(4)      = ydata{1}(1) - ydata{end}(1) + hightOfText(end)/2 + hightOfText(1)/2 + 2*legTightInsetYTemp;
            obj.extent         = extentTemp;
            obj.legTightInsetY = legTightInsetYTemp;
            obj.heightOfText   = hightOfText;
            
            % Coordinates used for the xlim and ylim properties
            % of the legend axes
            %------------------------------------------------------
            xlim = [extentTemp(1), extentTemp(1) + extentTemp(3)];
            ylim = [extentTemp(2), extentTemp(2) + extentTemp(4)];
            
            % Interpret color options
            %------------------------------------------------------
            if ischar(obj.color) 
                if ~strcmpi(obj.color,'none')
                    cData = nb_plotHandle.interpretColor(obj.color);
                else
                    cData = obj.color; 
                end
            else
                cData = obj.color;
            end
            
            % Construct the axes to plot the legend on
            %------------------------------------------------------
            if isa(obj.parent.parent,'nb_figure')
                if isa(obj.parent.parent,'nb_graphPanel')
                    if verLessThan('matlab','8.4')
                        figureHandle = obj.parent.parent.figureHandle;
                    else
                        figureHandle = obj.parent.parent.panelHandle;
                    end
                else
                    figureHandle = obj.parent.parent.figureHandle;
                end
            else
                figureHandle = obj.parent.parent;
            end
            obj.plotHandle = axes('position',           obj.extent,...
                                  'color',              cData,...
                                  'xlim',               xlim,...
                                  'ylim',               ylim,...
                                  'xTick',              [],...
                                  'yTick',              [],...
                                  'box',                obj.box,...
                                  'visible',            'on',...
                                  'units',              'normalized',...
                                  'selectionHighlight', 'off',...
                                  'parent',             figureHandle,...
                                  'clipping' ,          'on',...
                                  'userData',           {obj},...      % This is used to update the properties of the nb_legend object when the figure resizes
                                  'tag',                'legendAxes'); % This tag is used to find the legend axes object when the figure resizes
            
            if strcmpi(obj.box,'off')
                set(obj.plotHandle,'Visible','off');
                set(get(obj.plotHandle,'Title'),'Visible','on');
            end
            
            % Get text spacer y (half of one line of text)
            numRowsOfLegend = max(numRowsOfLegend,[],2);
            d               = 0;
            ind             = [];
            k               = 1;
            while isempty(ind)
                ind = find(numRowsOfLegend == k,1,'first');
                d   = d + 1;
                k   = k + 1;
            end
            textSpacerY = hightOfText(ind)/d;
            textSpacerY = textSpacerY/2;
            
            % Plot the legend
            %------------------------------------------------------
            chil = cell(1,totSize);
            for ii = 1:totSize    
                chil{ii} = obj.legendDetails(ii).plot(xdata{ii}, ydata{ii}, textSpacer, textSpacerY, obj, obj.plotHandle, legs{ii},fontU,fontS); 
            end
            
            % Assign all to the children
            %------------------------------------------------------
            obj.children = nb_nestedCell2Cell(chil);
              
        end
        
        %------------------------------------------------------------------
        function [fontU,fontS] = getFontSize(obj)
            
            if ~strcmpi(obj.fontUnits,'points')
                
                if strcmpi(obj.normalized,'axes')
                    axh = obj.parent.plotAxesHandle;
                else
                    if isa(obj.parent.parent,'nb_graphPanel')
                        axh = axes('position',[0.1 0.1 0.8 0.8],'visible','off','parent',obj.parent.parent.panelHandle);
                    else
                        axh = axes('position',[0.1 0.1 0.8 0.8],'visible','off','parent',obj.parent.parent.figureHandle);
                    end
                end
                t = text(0,2,'test',...
                         'fontUnits',   obj.fontUnits,...
                         'fontSize',    obj.fontSize,...
                         'interpreter', obj.interpreter,...
                         'parent',      axh,...
                         'clipping',    'off',...
                         'visible',     'off');
                set(t,'fontUnits','points');
                drawnow;
                fontS = get(t,'fontSize');
                fontU = 'points';
                delete(t);
                
                if ~strcmpi(obj.normalized,'axes')
                    delete(axh);
                end
                
            else
                fontU = obj.fontUnits;
                fontS = obj.fontSize;
            end
            
        end
        
        function getLegendInformation(obj)
        % Get the legend information of the children of the nb_axes  
        % handle (Given by the 'parent' property)   
            
            % Get the parents children
            %--------------------------------------------------------------
            plotH = obj.parent.children;
            
            % Get the information of the plotted data
            %--------------------------------------------------------------
            leg = [];
            for ii = 1:size(plotH,2)
                % Here we are dealing with nb_legendDetails objects
                leg = [leg, plotH{ii}.getLegendInfo()]; %#ok
            end
            
            % Remove leg info with line style 'none'
            indR = strcmp('line',{leg.type}) & strcmp('none',{leg.lineStyle}) & strcmp('none',{leg.lineMarker});
            leg  = leg(~indR);
            
            if ~isempty(obj.fakeLegends)
                fakeLegend = getFakeLegend(obj);
                leg        = [leg, fakeLegend];
            end
            
            % Assign to the property
            obj.legendDetails = leg;
            
        end
        
        function fakeLegend = getFakeLegend(obj)
        % Get the fake legend with line widths adjusted to match the axes 
        % scale factor.
        
            ax = obj.parent;
            
            fakeLegend = obj.fakeLegends;
            if ax.scaleLineWidth
                factor = ax.scaleFactor;
                numLeg = length(obj.fakeLegends);
                for ii = 1:numLeg
                    fakeLegend(ii).lineWidth = fakeLegend(ii).lineWidth * factor;
                end
            end
            
        end
        
        function obj = interpretFontColor(obj)
        % Interpret the fontColor property
        
            totSize    = size(obj.legendDetails,2);
            fontColors = vertcat(obj.legendDetails.fontColor);
            ind        = all(fontColors == 0,2);
            
            if isnumeric(obj.fontColor)

                if size(obj.fontColor,2) ~= 3
                    error([mfilename ':: The fontColor property must when set to a double have 3 columns with the RGB colors'])
                else

                    if size(obj.fontColor,1) == 1
                        [obj.legendDetails(ind).fontColor] = deal(obj.fontColor);
                    elseif size(obj.fontColor,1) == totSize
                        for ii = 1:totSize
                            obj.legendDetails(ii).fontColor = obj.fontColor(ii,:);
                        end
                    else
                        error([mfilename ':: The fontColor property when set to double must either have 1 row or has a many rows as the number of '...
                                         'of the plotted legends (' int2str(totSize) '). Is ' int2str(size(obj.fontColor,1))])
                    end

                end

            elseif ischar(obj.fontColor)

                fc = cellstr(obj.fontColor)';
                if size(fc,2) == 1
                    [obj.legendDetails(ind).fontColor] = deal(fc{1});
                elseif size(fc,2) == totSize
                    for ii = 1:totSize
                        obj.legendDetails(ii).fontColor = fc{ii};
                    end
                else
                    error([mfilename ':: The fontColor property must either provide 1 or ' int2str(totSize) ', '...
                                     'but you have only provided ' int2str(size(fc,2))])
                end

            elseif iscellstr(obj.fontColor)

                fc = obj.fontColor;
                if length(fc) == 1
                    [obj.legendDetails(ind).fontColor] = deal(fc{1});
                elseif length(fc) == totSize
                    for ii = 1:totSize
                        obj.legendDetails(ii).fontColor = fc{ii};
                    end
                else
                    error([mfilename ':: The fontColor property must either provide 1 or ' int2str(totSize) ', '...
                                     'but you have only provided ' int2str(size(fc,2))])
                end

            end
            
        end
            
        function [obj,legs] = interpretLegends(obj)
        % Reorders the nb_legendDetails objects and legend text 
        % array. It also remove unwanted legends (The legends with 
        % empty strings)
        
            % If a legend text is empty, we skip it in the legend
            %----------------------------------------------------------
            indexLeg = ~cellfun(@isempty,obj.legends);

            % Remove the unwanted legends
            %----------------------------------------------------------
            numberOfLegends = size(obj.legends,2);
            legs            = obj.legends(indexLeg);

            % Remove the unwanted lines
            %----------------------------------------------------------
            totSize = size(obj.legendDetails,2);
            if totSize == 0
                index = 0;
            elseif totSize <= numberOfLegends
                index = totSize;
            else
                index = numberOfLegends;
            end

            obj.legendDetails = obj.legendDetails(indexLeg(1:index));
        
            % Reorder the legend if wanted
            %--------------------------------------------------
            if ischar(obj.reorder)

                if strcmpi('inverse',obj.reorder)

                    % Here we need to invert the legend details
                    legD  = obj.legendDetails;
                    legD2 = [];
                    for ii = 0:size(legD,2) - 1

                        legD2 = [legD2, legD(end-ii)]; %#ok

                    end
                    obj.legendDetails = legD2;

                    % Invert the legend text array
                    legs = fliplr(legs);

                end

            elseif isnumeric(obj.reorder)

                legD  = obj.legendDetails;
                legD2 = [];
                rO    = obj.reorder;
                try

                    % Reorder the nb_legendDetails objects
                    for ii = rO

                        legD2 = [legD2, legD(ii)]; %#ok

                    end
                    obj.legendDetails = legD2;

                    % Reorder the legend text array
                    legs = legs(rO);

                catch Err

                    sizelegD = size(legD,2);
                    sizeRO   = size(rO);
                    if sizeRO(1) ~= 1 && sizeRO(2) == sizelegD
                        error([mfilename ':: The size of the double provided to the property ''reorder'' (' int2str(sizeRO(1)) 'x' int2str(sizeRO(2)) ') '...
                                         'doesn''t fit the size of the plotted legends (1x' int2str(sizelegD) ').'])
                    else
                        rethrow(Err)
                    end

                end

            else
                error([mfilename ':: The reorder property can only be a string (''default'' | ''inverse'') or a double vector with the how to reorder the legend.'])
            end
            
        end
        
        function ret = isActive(obj)
            
            if isempty(obj.children) || obj.fast
                ret = true;
                return
            end
            
            ind    = cellfun(@(x)isa(x,'nb_patch'),obj.children);
            child1 = obj.children(ind);
            child2 = obj.children(~ind);
            if isempty(child1)
                ret1 = true;
            else
                ret1 = all(isvalid([child1{:}]));
            end
            if isempty(child1)
                ret2 = true;
            else
                ret2 = all(ishandle([child2{:}]));
            end
            ret    = ret1 & ret2;
            
        end
        
        function mouseMoveCallback(obj, ~, ~)
        
            if ~isvalid(obj) || ~isActive(obj) || obj.fast
                return
            end
            
            pointer = [];
            if obj.selected
                pointer = obj.pointer;
            else     
                
                if isempty(obj.parent)
                    return
                end

                cAxPoint = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                ext      = obj.extent;

                % Check if the user have selected one of the resize
                % positions
                %------------------------------------------------------
                xx = cAxPoint(1);
                yy = cAxPoint(2);

                test1 = xx > ext(1);
                test2 = xx < ext(1) + ext(3);
                test3 = yy > ext(2);
                test4 = yy < ext(2) + ext(4);
                
                % Assign callback
                %------------------------------------------------------
                if test1 && test2 && test3 && test4
                    % We also set the type of selction
                    pointer           = 'hand';
                    obj.selectionType = 'move';
                else
                    obj.selectionType = 'none';
                end
                
            end
            
            obj.pointer = pointer;          
            if ~isempty(obj.pointer)
                set(obj.parent.parent.figureHandle, 'pointer', obj.pointer);
            end
            
        end
        
        function mouseDownCallback(obj,~,~)
        % This function is called when the user click while holding
        % the mouse above this object. 
            
            if ~isvalid(obj) || ~isActive(obj) || obj.fast
                return
            end
        
            % Get figure handle
            fig = obj.parent.parent.figureHandle;
            
            % What to do
            sel_typ = get(fig,'SelectionType');
            switch sel_typ
                case 'normal'
                    
                    switch obj.selectionType
                        
                        case 'start'
                            obj.selected = 1;
                        case 'end'
                            obj.selected = 1;
                        case 'move'
                            obj.selected = 1;
                            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                            obj.startPoint    = [cPoint;cAxPoint];
                        otherwise
                            obj.selected = 0;
                            
                    end
            end
            
        end
        
        function mouseUpCallback(obj, ~, ~)
            
            if ~isvalid(obj) || ~isActive(obj) || ~obj.selected  || obj.fast
                return
            end
            
            switch obj.selectionType
                case 'start'
                    obj.startMove();
                case 'end'
                    obj.endMove();
                case 'move'
                    obj.move();
            end
            obj.selected = 0;
            
        end
        
        function startMove(obj,~,~)
        % Resize not possible   
            
            obj.selected = 0;
            
        end
        
        function endMove(obj,~,~)
        % Resize not possible   
            
            obj.selected = 0;
            
        end
        
        function move(obj,~,~)
            
            % Get the new value
            %------------------------------------------------------
            [~,cAxPoint]  = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            axesPositions = get(obj.parent.plotAxesHandle,'Position');
            
            % Update the arrow
            %------------------------------------------------------
            if isempty(obj.position)
                obj.position(1) = (obj.extent(1) - axesPositions(1))/axesPositions(3) + cAxPoint(1) - obj.startPoint(2,1);
                obj.position(2) = (obj.extent(2) + obj.extent(4) - axesPositions(2))/axesPositions(4) + cAxPoint(2) - obj.startPoint(2,2);
            else
                obj.position(1) = obj.position(1) + cAxPoint(1) - obj.startPoint(2,1);
                obj.position(2) = obj.position(2) + cAxPoint(2) - obj.startPoint(2,2);
            end
            update(obj);
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function onFigureResize(obj)
            drawnow();
            try
                obj.parent.updateLegend();
            catch Err
                warning('nb_legend:onFigureResize',['Could not update legend upon resize. Error:: ' Err.message])
            end
        end
        
    end
    
    methods(Static=true,Access=protected)
        
        
    end
    
end
