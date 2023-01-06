classdef nb_line < nb_plotHandle
% Syntax:
%     
% obj = nb_line(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for plotting a line. (only 2D)
%     
% Extra functionalities:
%
% - The line style '---' is supported.
%     
% Caution: Some functionalities of the MATLAB line command is not 
%          supported.
%     
%          Important: 
%          - z-dimension is not supported
%          - Only possible to plot one line at a time.
%     
% Constructor:
%     
%     obj = nb_line(xData,yData,varargin)
%     
%     Input:
%         
%     - xData : The x-axis values of the plotted line. If only one 
%               input is given to this constructor it will be 
%               interpreted as the yData input. (Then the xData 
%               will be 1:size(yData,1)). Must be a double 
%               vector.
% 
%     - yData : The y-axis values of the plotted line. Must be a 
%               double vector.
% 
%     Optional input:
% 
%     - varargin : ...,'propertyName',propertyValue,...
%    
%     Output:
% 
%     - obj : An object of class nb_line
%     
%     Examples:
% 
%         nb_line([0,2]);
% 
%             same as 
% 
%         nb_line([0,1],[0,2]);
% 
%         nb_line([0,1],[0,2],'propertyName',propertyValue,...);
% 
%         e.g.
% 
%         nb_line([0,1],[0,2],'cData',{'red'},'lineWidth',1.5);   
% 
%         Return the handle to the plotted line:
% 
%         l = nb_line([0,1],[0,2],'cData',{'red'},'lineWidth',1.5); 
% 
%         Which you can use to set and get properties:
% 
%         l.set('lineWidth',1);
%         lw = l.get('lineWidth');       
%  
% See also:
% line
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties(SetAccess = protected)
       
        % The children of the handle. As line handle(s).
        children            = [];    
        
    end

    properties
        
        % The color data of the line plotted. Must be of size;
        % 1 x 3. With the RGB colors. Or a string with the name
        % of the color. See the method interpretColor of the 
        % nb_plotHandle class for more on the supported color 
        % names.
        cData               = [];           
        
        % {'on'} | 'off' ; Clipping mode. MATLAB clips lines to the 
        % axes plot box by default. If you set Clipping to off, 
        % lines are displayed outside the axes plot box.
        clipping            = 'on';          

        % Lenght of the dashes of the '---' lineStyle.
        dashLength          = 0.15;         
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption        = 'only';      
        
        % Lenght of the gaps of the '---' lineStyle
        gapLength           = 0.05;   
        
        % 'off' : Not included in the legend. {'on'} : 
        % included in the legend
        legendInfo          = 'on';         
        
        % The line style of the plotted data. Either a 
        % string or a cell array with size as the 
        % number of lines to be plotted. {'-'} | '--' |
        % '---' | ':' | '-.' | 'none'
        lineStyle           = '-';          
        
        % The line width of the plotted data. Must be a scalar. 
        % Default is 2.5.
        lineWidth           = 2.5;        
        
        % The markers of the lines. Either a string or 
        % a cell array with size as the number of lines 
        % to be plotted. See marker property of the 
        % MATLAB line function for more on the options 
        % of this property
        marker              = 'none';       
              
        % A 1x3 double with the RGB colors | 'none' | 
        % {'auto'} | a string with the color name.
        markerEdgeColor     = 'auto';       
        
        % A 1x3 double with the RGB colors | 'none' | 
        % {'auto'} | a string with the color name.
        markerFaceColor     = 'auto';       
        
        % Size of the markers. Default is 9.
        markerSize          = 9;
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default)
        side                = 'left';
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'.
        visible             = 'on'; 
        
        % The x-axis data. As a double vector.
        xData               = [];           
        
        % The x-axis limits as 1x2 double. Default is 
        % to use the axes limits (If they are 
        % smaller then the data limits, the data limits
        % will be used instead). This property is only 
        % used for the line style '---' 
        xLim                = []; 
        
        % The y-axis data. As a double vector.
        yData               = [];           
        
        % The y-axis limits as 1x2 double. Default is 
        % to use the axes limits (If they are 
        % smaller then the data limits, the data limits
        % will be used instead). This property is only
        % used for the line style '---' 
        yLim                = [];           
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        type = 'line';
        
    end
    
    %======================================================================
    % The accessible methods of the class
    %======================================================================
    methods
               
        function obj = nb_line(xData,yData,varargin)
            
            if nargin == 1
                
                obj.yData = xData;
                obj.xData = 1:length(xData);
                
                % Then just plot
                plotLine(obj);
                
            elseif nargin > 1
                
                obj.xData = xData;
                if ~isnumeric(yData)
                    error([mfilename ':: Input ''yData'' must be a double. Is ' class(yData)])
                end
                obj.yData = yData;
                
                if nargin > 2
                    obj.set(varargin);
                else
                    % Then just plot
                    plotLine(obj);
                end
                
            end
            
        end
        
        function set.cData(obj,value)
            if ~nb_isColorProp(value,1)
                error([mfilename ':: The cData property must'...
                    ' must have dimension size'...
                    ' size(plotData,2) x 3 with the RGB'...
                    ' colors or a cellstr with size 1 x'...
                    ' size(yData,2) with the color names.'])
            end
            obj.cData = value;
        end
        
        function set.clipping(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The clipping property must be'...
                                 ' set to either ''on'' or ''off''.'])
            end
            obj.clipping = value;
        end

        function set.dashLength(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The dashLength property must be'...
                                 ' given as a scalar.'])
            end
            obj.dashLength = value;
        end
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.gapLength(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The gapLength property must be'...
                                 ' given as a scalar.'])
            end
            obj.gapLength = value;
        end
        
        function set.legendInfo(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The legendInfo property must be'...
                                 ' set to either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
        end        
        
        function set.lineStyle(obj,value)
            if ~nb_islineStyle(value,1)
                error([mfilename ':: The lineStyle property must be'...
                                 ' set to a valid line style.'])
            end
            obj.lineStyle = value;
        end            
        
        function set.lineWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The lineWidth property must be'...
                                 ' given as a scalar.'])
            end
            obj.lineWidth = value;
        end        
        
        function set.marker(obj,value)
            if ~nb_ismarker(value,1)
                error([mfilename ':: The marker property must be set to'...
                       ' a valid marker value.'])
            end
            obj.marker = value;
        end           
        
        function set.markerEdgeColor(obj,value)
            if ~nb_isColorProp(value,1) 
                error([mfilename ':: The markerEdgeColor property must'...
                                 ' must have dimension size'...
                                 ' 1 x 3 with the RGB colors'...
                                 ' or a one line character array with'...
                                 ' ''none'' or ''auto''.'])
            end
            obj.markerEdgeColor = value;
        end        
        
        function set.markerFaceColor(obj,value)
            if (~nb_isColorProp(value) && ~all([1 3] == size(value))) && ...
                                    ~any(strcmp({'none','auto'},value))
                error([mfilename ':: The markerFaceColor property must'...
                                 ' must have dimension size'...
                                 ' 1 x 3 with the RGB colors'...
                                 ' or a one line character array with'...
                                 ' ''none'' or ''auto''.'])
            end
            obj.markerFaceColor = value;
        end            
        
        function set.markerSize(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The markerSize property must be'...
                                 ' given as a scalar.'])
            end
            obj.markerSize = value;
        end 
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename ':: The side property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.side = value;
        end   
        
        function set.visible(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The visible property must be set to'...
                      'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end       
        
        function set.xData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The xData property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.xData = value;
        end        
        
        function set.xLim(obj,value)
            if ~all(ismember([1 2],size(value))) && ~isempty(value)
                error([mfilename ':: The xLim property must be given'...
                   ' as a 1x2 double.'])
            end
            obj.xLim = value;
        end
        
        function set.yData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.yData = value;
        end    
        
        function set.yLim(obj,value)
            if ~all(ismember([1 2],size(value))) && ~isempty(value)
                error([mfilename ':: The yLim property must be given'...
                   ' as a 1x2 double.'])
            end
            obj.yLim = value;
        end     
              
        varargout = set(varargin)
        
        varargout = get(varargin)
        
        function lineWidth = get.lineWidth(obj)
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
        end
        
        function markerSize = get.markerSize(obj)
           markerSize = nb_scaleLineWidth(obj,obj.markerSize); 
        end
        
        %{
        ---------------------------------------------------------------
        Delete the object
        ---------------------------------------------------------------
        %}
        function delete(obj)
            
            % Remove it form its parent
            if isa(obj.parent,'nb_axes')
                if ishandle(obj.parent.axesHandle)
                    obj.parent.removeChild(obj);
                end
            end

            if strcmpi(obj.deleteOption,'all')
                
                if isempty(obj.children)
                    return
                end
                
                % Delete all the children of the object 
                for ii = 1:size(obj.children,2)
                    if ishandle(obj.children(ii))
                        delete(obj.children(ii))
                    end
                end
                
            end
             
        end
        
        %{
        -------------------------------------------------------------------
        Find the x-axis limits of this object
        -------------------------------------------------------------------
        %}
        function xlimit = findXLimits(obj)
        
            xlimit = [min(obj.xData),max(obj.xData)];
            
        end
            
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
            
            dataLow  = obj.yData;
            dataHigh = obj.yData;
            
            % Find the method to use
            if isa(obj.parent,'nb_axes')
                method = obj.parent.findAxisLimitMethod;
                if isa(obj.parent.parent,'nb_figure')
                    fig = obj.parent.parent.figureHandle;
                else
                    fig = obj.parent.parent;
                end
            else
                method = 4;
                fig    = get(obj.parent,'parent');
            end
            
            ylimit = nb_plotHandle.findLimitsAlgo(dataLow,dataHigh,method,fig);
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the visible property. This method should only be called from 
        the parent, when its visible property is set to 'off'
        -------------------------------------------------------------------
        %}
        function setVisible(obj)
            
            obj.visible = get(obj.parent,'visible');
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the legend info from this object. Used by the nb_legend class
        -------------------------------------------------------------------
        Output:
        
        - legendDetails : An nb_legendDetails object. If the 'legendInfo'
                          property is set to 'off'. It will return an empty
                          double, i.e. [];
        
        -------------------------------------------------------------------
        %}
        function legendDetails = getLegendInfo(obj)
            
            ld = nb_legendDetails();
            
            if strcmpi(obj.legendInfo,'on')
                
                ld.lineColor            = obj.cData;             
                ld.lineStyle            = obj.lineStyle;
                ld.lineWidth            = obj.lineWidth;
                ld.lineMarker           = obj.marker;
                ld.lineMarkerEdgeColor  = obj.markerEdgeColor;
                ld.lineMarkerFaceColor  = obj.markerFaceColor;
                ld.lineMarkerSize       = obj.markerSize;
                ld.side                 = obj.side;
                
            else
              
                ld = [];
                
            end
            
            legendDetails = ld;
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the nb_line object. E.g. when you have set properties
        outside the set method.
        -------------------------------------------------------------------
        %}
        function update(obj)
           
            plotLine(obj);
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Plot the line
        -------------------------------------------------------------------
        %}
        function plotLine(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                for ii = 1:length(obj.children)
                    delete(obj.children(ii));
                end
                obj.children = [];
            end
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,2) ~= 1
                if size(obj.xData,1) == 1
                    obj.xData = obj.xData';
                else
                    error([mfilename ':: The ''xData'' property has not only one column or only one row.'])
                end   
            end
            
            if size(obj.yData,2) ~= 1
                if size(obj.yData,1) == 1
                    obj.yData = obj.yData';
                else
                    error([mfilename ':: The ''yData'' property has not only one column or only one row.'])
                end 
            end
            
            if size(obj.xData,1) ~= size(obj.yData,1)
                error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same length.'])
            end
            
            if isempty(obj.cData)
                % Get the default color
                obj.cData = [51 51 51]/255; 
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,2) ~= 3 || size(obj.cData,1) ~= 1
                    error([mfilename ':: The ''cData'' property must be a 1x3 matrix with the rgb colors of the plotted data.'])
                end
                
            elseif ischar(obj.cData)
                
                if size(obj.cData,1) ~= 1
                    error([mfilename ':: The char given by ''cData'' property has not same number of rows (' int2str(size(obj.cData,1)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end    
                
            elseif iscell(obj.cData)
                
                if length(obj.cData) ~= 1
                    error([mfilename ':: The cellstr array given by ''cData'' property has not same length (' int2str(length(obj.cData)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            else
                
                error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])    
                
            end
            
            % Decide some colors.
            %--------------------------------------------------
            if ischar(obj.markerEdgeColor)
                if ~strcmpi(obj.markerEdgeColor,'auto')
                    obj.markerEdgeColor = nb_plotHandle.interpretColor(obj.markerEdgeColor);
                end
            end
            
            % Decide some colors.
            %--------------------------------------------------
            if ischar(obj.markerFaceColor)
                if ~strcmpi(obj.markerFaceColor,'auto')
                    obj.markerFaceColor = nb_plotHandle.interpretColor(obj.markerFaceColor);
                end
            end
            
            %--------------------------------------------------------------
            % Start the plotting
            %--------------------------------------------------------------
            if strcmp(obj.lineStyle,'---')
                
                l = dashLine(obj);
                
            else
                
                %----------------------------------------------------------
                % Decide the parent (axes to plot on)
                %----------------------------------------------------------
                if isempty(obj.parent)
                
                    obj.parent = nb_axes();
                    if strcmpi(obj.side,'right')
                        axh = obj.parent.plotAxesHandleRight;
                    else
                        axh = obj.parent.plotAxesHandle;
                    end

                else

                    if isa(obj.parent,'nb_axes')

                        if strcmpi(obj.side,'right')
                            axh = obj.parent.plotAxesHandleRight;
                        else
                            axh = obj.parent.plotAxesHandle;
                        end

                    else
                        axh = obj.parent;
                    end

                end
                
                if strcmpi(obj.markerFaceColor,'auto')
                    obj.markerFaceColor = obj.cData;
                end
                
                l = line(obj.xData,obj.yData,...
                                'clipping',         obj.clipping,...
                                'color',            obj.cData,...
                                'lineStyle',        obj.lineStyle,...
                                'lineWidth',        obj.lineWidth,...
                                'marker',           obj.marker,...
                                'markerEdgeColor',  obj.markerEdgeColor,...
                                'markerFaceColor',  obj.markerFaceColor,...
                                'markerSize',       obj.markerSize,...
                                'parent',           axh,...
                                'visible',          obj.visible);
                            
            end
            
            obj.children = l;
            
            if strcmpi(obj.legendInfo,'off')
                set(get(get(obj.children,'Annotation'),'LegendInformation'),...
                        'IconDisplayStyle','off'); 
            end 
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                
                % Update the axes given the plotted data
                obj.parent.addChild(obj);
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Plot longer dashed lines
        -------------------------------------------------------------------
        Some of the code is borrowed from:
        
        Kluged together by Edward Abraham (e.abraham@niwa.cri.nz) 
        27-Sept-2002 Minor change made so that it works with Matlab 6.5
        27-June-2002 Original version
        -------------------------------------------------------------------
        %}
        function handle = dashLine(obj)
            
            % Assign properties
            xdata = obj.xData;
            ydata = obj.yData;
            dash1 = obj.dashLength;
            gap1  = obj.gapLength;
            
            % Remove nan data
            isNaN = isnan(ydata);
            xdata = xdata(~isNaN);
            ydata = ydata(~isNaN);
            
            %--------------------------------------------------------------
            % Decide the parent (axes to plot on)
            %--------------------------------------------------------------
            if isempty(obj.parent)
                
                obj.parent = nb_axes();
                if strcmpi(obj.side,'right')
                    axh = obj.parent.plotAxesHandleRight;
                else
                    axh = obj.parent.plotAxesHandle;
                end
                
            else
                
                if isa(obj.parent,'nb_axes')
                    
                    if strcmpi(obj.side,'right')
                        axh = obj.parent.plotAxesHandleRight;
                    else
                        axh = obj.parent.plotAxesHandle;
                    end
                    
                else
                    axh = obj.parent;
                end
                
            end
            
            %--------------------------------------------------------------
            % I need to find the axes limits
            %--------------------------------------------------------------
            if ~isempty(obj.xLim) && ~isempty(obj.yLim)
                
                XLim = obj.xLim;
                YLim = obj.yLim;
                
            else
                
                XLim = findXLimits(obj);
                YLim = findYLimits(obj);
                
                if ~isempty(get(obj.parent,'children'))
                    yLimAxes = get(obj.parent,'yLim');
                    xLimAxes = get(obj.parent,'xLim');
                else
                    yLimAxes = YLim;
                    xLimAxes = XLim;
                end

                XLim = [min([XLim(1),xLimAxes(1)]), max([XLim(2),xLimAxes(2)])];
                YLim = [min([YLim(1),yLimAxes(1)]), max([YLim(2),yLimAxes(2)])];
                
            end

            %--------------------------------------------------------------
            % Get Axes properties ...
            %--------------------------------------------------------------
            IsXLog    = strcmp(get(axh,'XScale'),'log');
            IsYLog    = strcmp(get(axh,'YScale'),'log');
            Position  = get(axh,'Position');

            %--------------------------------------------------------------
            % Work out position of datapoints...
            %--------------------------------------------------------------
            if ~IsXLog
                xpos = (xdata-XLim(1))/(XLim(2)-XLim(1))*Position(3);
            else
                xpos = (log10(xdata)-log10(XLim(1)))/(log10(XLim(2))-log10(XLim(1)))*Position(3);
            end

            if ~IsYLog
                ypos = (ydata-YLim(1))/(YLim(2)-YLim(1))*Position(4);
            else
                ypos = (log10(ydata)-log10(YLim(1)))/(log10(YLim(2))-log10(YLim(1)))*Position(4);
            end

            f = find(~isreal(xpos) | isinf(xpos)  | isnan(xpos) | ~isreal(ypos) | isinf(ypos)  | isnan(ypos));
            if ~isempty(f)
                xpos(f)  = [];
                ypos(f)  = [];
                xdata(f) = [];
                ydata(f) = [];
            end
            
            %--------------------------------------------------------------
            % Calculate distance from the start of the line (in mm) ...
            %--------------------------------------------------------------
            dist = [0;cumsum(sqrt(diff(xpos).^2 + diff(ypos).^2))*10];

            start1           = gap1:dash1 + gap1:dist(end);
            dashesY          = zeros(3*length(start1),1);
            dashesY(1:3:end) = nan;
            dashesY(2:3:end) = start1;
            dashesY(3:3:end) = start1 + dash1;

            dashesX = dashesY;

            xdash = nan(length(dashesY),1);
            ydash = nan(length(dashesY),1);

            %--------------------------------------------------------------
            % Straight dashes ...
            %--------------------------------------------------------------
            if ~IsXLog
                xdash(1:length(dashesX)) = interp1(dist, xdata, dashesX);
            else
                xdash(1:length(dashesX)) = 10.^interp1(dist, log10(xdata), dashesX);
            end 
            if ~IsYLog
                ydash(1:length(dashesY)) = interp1(dist, ydata, dashesY);
            else
                ydash(1:length(dashesY)) = 10.^interp1(dist, log10(ydata), dashesY);
            end 

            %--------------------------------------------------------------
            % Insert data points that fall within dashes (allows dashes to 
            % curve...)
            %--------------------------------------------------------------
            count            = 0;
            xlen             = length(xdash);
            dashstart        = zeros(length(start1),1);
            dashstart(1:end) = 2:3:length(dashesY);
            for j = 1:length(dashstart)

                f = find(dist > dashesY(dashstart(j)) & dist < dashesY(dashstart(j)+1));
                if length(f)>0 %#ok
                    xdash(dashstart(j) + count + length(f) + 1:xlen + length(f))     = xdash(dashstart(j)+count+1:xlen);
                    xdash(dashstart(j) + count + 1:dashstart(j) + count + length(f)) = xdata(f);
                    ydash(dashstart(j) + count + length(f) + 1:xlen + length(f))     = ydash(dashstart(j)+count+1:xlen);
                    ydash(dashstart(j) + count + 1:dashstart(j) + count + length(f)) = ydata(f);
                    xlen  = xlen+length(f);
                    count = count + length(f);
                end

            end

            if strcmpi(obj.markerFaceColor,'auto')
                obj.markerFaceColor = obj.cData;
            end
            
            %--------------------------------------------------------------
            % Plot line and markers ...
            %--------------------------------------------------------------
            handle = line(xdash, ydash,... 
                          'clipping',         obj.clipping,...
                          'color',            obj.cData,...
                          'lineStyle',        '-',...
                          'lineWidth',        obj.lineWidth,...
                          'marker',           obj.marker,...
                          'markerEdgeColor',  obj.markerEdgeColor,...
                          'markerFaceColor',  obj.markerFaceColor,...
                          'markerSize',       obj.markerSize,...
                          'parent',           axh,...
                          'visible',          obj.visible);

        end
        
    end
    
end
