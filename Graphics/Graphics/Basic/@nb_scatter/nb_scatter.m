classdef nb_scatter < nb_plotHandle & nb_notifiesMouseOverObject
% Syntax:
%     
% obj = nb_scatter()
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% Create scatter plot
%     
% Constructor:
%     
%     obj = nb_scatter()
%     
%     The constructor of the nb_scatter class
% 
%     Input:
%
%     - xData    : See below
%
%     - yData    : See below
%
%     Optional inputs:
%
%     - varargin : ...,'propertyName',propertyValue,...
% 
%     Output:
% 
%     - obj      : An object of class nb_scatter
%     
% See also:
% scatter
%     
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Protected properties of the object
    %======================================================================
    properties (SetAccess = protected)
        
        % The children of the object. As MATLAB scatter objects.
        children        = [];      
                
        type            = 'line';
        
    end
    
    %======================================================================
    % Properties of the class
    %======================================================================
    properties
        
        % Color of the plotted data. A matrix; 
        % size(yData,2) x 3 (RGB color). Or a cellstr
        % with the color names. (With size 1 x size(yData,2))
        cData               = [];      
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption        = 'only';  
        
        % {'off'} : Not included in the legend. 'on' : included in 
        % the legend. 
        legendInfo          = 'on';         
        
        % Line style of the line connecting the markers. Default is 'none'.
        lineStyle           = 'none';
        
        % Line width of line if plotted. Must be a scalar double.
        lineWidth           = 2.5;
        
        % Sets the marker of the plot. Either {'o'} | 'x' | '+' | 
        % '*' | 's' | 'd' | '.' | '^' | '<' | '>' | 'v' | 'p' | 
        % 'h'. Must be a string or a cellstr with size 
        % 1 x size(yData,2).
        marker              = 'o'; 
        
        % Sets the size of the markers. Must be a scalar.
        markerSize          = 8;            
                 
        % {'left'} | 'right' ; Which axes to plot on. Only
        % if the parent is of class nb_axes. (Which is 
        % the default)
        side                = 'left';       
        
        % Sets the visibility of the radar plot. {'on'} | 'off'.
        visible             = 'on';         
        
        % A double matrix. Each column will be match 
        % against the corresponding column of th yData
        % property. If it is given as a vector it will
        % be expanded to fit the number of columns of the
        % yData property.
        xData               = [];
        
        % A double matrix. Each column will be match 
        % against the corresponding column of th xData
        % property. If it is given as a vector it will
        % be expanded to fit the number of columns of the
        % xData property.
        yData               = [];            
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function set.cData(obj,value)
            if ~nb_isColorProp(value,true)
                error([mfilename ':: The cData property must'...
                                 ' must have dimension size'...
                                 ' size(plotData,2) x 3 with the RGB'...
                                 ' colors or a cellstr with size 1 x'...
                                 ' size(yData,2) with the color names.'])
            end
            obj.cData = value;
        end
        
        function set.deleteOption(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The deleteOption property must be'...
                                 ' set to a one line character array.'])
            end
            obj.deleteOption = value;
        end
        
        function set.legendInfo(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The legendInfo property must be'...
                                 ' set to a one line character array.'])
            end
            obj.legendInfo = value;
        end
        
        function set.lineStyle(obj,value)
            if ~nb_islineStyle(value)
                error([mfilename ':: The lineStyle property must be'...
                                 ' set to a valide lineStyle property.'])
            end
            obj.lineStyle = value;
        end
        
        function set.lineWidth(obj,value)
            if ~isscalar(value)
                error([mfilename ':: The lineWidth property must be'...
                                 ' set to a scalar double.'])
            end
            obj.lineWidth = value;
        end
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename ':: The side property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.side = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The visible property must be'...
                                 ' set to either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
        
        function set.xData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The xData property must be'...
                                 ' given as a double matrix.'])
            end
            obj.xData = value;
        end
        
        function set.yData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be'...
                                 ' given as a double matrix.'])
            end
            obj.yData = value;
        end

        function set.marker(obj,value)
            if ~nb_ismarker(value,true)
                error([mfilename ':: The marker property must be set to'...
                       ' a valid marker value.'])
            end
            obj.marker = value;
        end        
        
        function obj = nb_scatter(xData,yData,varargin)
            
            obj.xData = xData;
            obj.yData = yData;
            
            % Set other properties and plot
            obj.set(varargin{:});
            
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
                if isvalid(obj.parent)
                    obj.parent.removeChild(obj);
                end
            end

            if strcmpi(obj.deleteOption,'all')
                
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
        
            xlimit = [min(min(obj.xData)),max(max(obj.xData))];
            corr   = diff(xlimit)*1/20;
            
            if corr == 0
                corr = 1;
            end
            
            xlimit(1) = xlimit(1) - corr;
            xlimit(2) = xlimit(2) + corr;
            
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
            
            ylimit    = nb_plotHandle.findLimitsAlgo(dataLow,dataHigh,method,fig);
            corr      = diff(ylimit)*1/20;
            ylimit(1) = ylimit(1) - corr;
            ylimit(2) = ylimit(2) + corr;
            
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
        
        - legendDetails : An 1 x M array of nb_legendDetails, where M is 
                          the number of children of this object which has 
                          it 'legendInfo' property set to 'on'. If this 
                          object property 'legendInfo' is set to 'off' 
                          this method will return [].
        
        -------------------------------------------------------------------
        %}
        function legendDetails = getLegendInfo(obj)
            
            legendDetails(1,size(obj.yData,2)) = nb_legendDetails();
            if strcmpi(obj.legendInfo,'on')
            
                % Loop through the children (nb_patch objects)
                for ii = 1:size(obj.yData,2)
            
                    legendDetails(1,ii).lineColor            = obj.cData(ii,:);             
                    legendDetails(1,ii).lineStyle            = obj.lineStyle;
                    legendDetails(1,ii).lineWidth            = obj.lineWidth;
                    legendDetails(1,ii).lineMarker           = obj.marker{ii};
                    legendDetails(1,ii).lineMarkerEdgeColor  = obj.cData(ii,:);
                    legendDetails(1,ii).lineMarkerFaceColor  = obj.cData(ii,:);
                    legendDetails(1,ii).lineMarkerSize       = obj.markerSize;
                    legendDetails(1,ii).type                 = 'line';

                end
                     
            end
            
        end
        
    end
    
    methods(Hidden=true)
       
       function [x,y,value] = notifyMouseOverObject(obj,cPoint)
       % cPoint : current point in data units
            
            if isa(obj.parent,'nb_axes')  
                if strcmpi(obj.side,'right')
                    ax = obj.parent.plotAxesHandleRight;
                else
                    ax = obj.parent.plotAxesHandle;
                end
            else
                ax = obj.parent;
            end
            
            % Work in normal units
            normalLimits = [0 1];
            xPointer     = nb_pos2pos(cPoint(1), get(ax, 'xLim'), normalLimits, get(ax, 'xScale'));
            yPointer     = nb_pos2pos(cPoint(2), get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));
            xDataNormal  = nb_pos2pos(obj.xData, get(ax, 'xLim'), normalLimits, get(ax, 'xScale'));
            yDataNormal  = nb_pos2pos(obj.yData, get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));

            % Find closest data point
            distances              = (xDataNormal - xPointer) .^ 2 + (yDataNormal - yPointer) .^ 2;
            [closestDistance, ind] = min(distances(:));
            closestDistance        = sqrt(closestDistance);
            [x, y]                 = ind2sub(size(distances), ind);
            
            threshold = 0.015; 
            if closestDistance < threshold
                value(1) = obj.xData(x, y);
                value(2) = obj.yData(x, y);
            else
                x     = [];
                y     = [];
                value = [];
            end
            
       end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        function scatterPlot(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                for ii = 1:length(obj.children)
                    if ishandle(obj.children(ii))
                        delete(obj.children(ii));
                    end
                end
                obj.children = [];
            end
            
            % Test the data inputs
            %------------------------------------------------------
            sYData = size(obj.yData);
            sXData = size(obj.xData);
            if sXData(1) == 1 && sXData(2) >= 1
                obj.xData = obj.xData';
            end
            
            if sYData(1) == 1 && sYData(2) >= 1
                obj.yData = obj.yData';
            end
            
            sYData = size(obj.yData);
            sXData = size(obj.xData);
            if sYData(2) ~= sXData(2)
                
                if sXData(2) == 1
                    obj.xData = repmat(obj.xData,1,sYData(2));
                else
                    error([mfilename ':: Dimension mismatch of ''yData'' (' int2str(sYData(1)) 'x' int2str(sYData(2)) ') '...
                                     'and ''xData'' (' int2str(sXData(1)) 'x' int2str(sXData(2)) ') properties.'])
                end
                
            end
            %------------------------------------------------------
            
            sData  = size(obj.yData,2);
            
            % Test the colors provided
            %------------------------------------------------------
            if isempty(obj.cData)
                
                obj.cData = nb_plotHandle.getDefaultColors(sData);
                
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,2) ~= 3
                    error([mfilename ':: The ''cData'' property must be a Mx3 matrix with the rgb colors of the plotted data.'])
                elseif size(obj.cData,1) ~= sData
                    error([mfilename ':: The ''cData'' property has not as many rows (' int2str(size(obj.cData,1)) ') as the property ''yData'' has columns. (' int2str(sData) ')'])
                end
                
            elseif iscell(obj.cData)
                
                if length(obj.cData) ~= sData
                    error([mfilename ':: The cellstr array given by ''cData'' property has not same length (' int2str(length(obj.cData)) ') as the property ''yData'' has columns. (' int2str(sData) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            elseif ischar(obj.cData)
                
                if size(obj.cData,1) ~= sData
                    error([mfilename ':: The char given by ''cData'' property has not same number of rows (' int2str(size(obj.cData,1)) ') as the property ''yData'' has columns. (' int2str(sData) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            else
                
                error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])    
                
            end
            
            % Test the markers provided
            %------------------------------------------------------
            if ischar(obj.marker)
                
                mark = obj.marker(1,:);
                m = cell(1,sData);
                for ii = 1:sData
                    m{ii} = mark;
                end
                obj.marker = m;
                
            elseif iscellstr(obj.marker)
                
                if size(obj.marker,2) == sData 
                    obj.marker = obj.marker(1,:);
                elseif size(obj.marker,1) == sData 
                    obj.marker = obj.marker(:,1)';
                else
                    error([mfilename ':: The number of markers don''t fit the number of columns of the ''yData'' property.'])
                end
                
            end
            
            %--------------------------------------------------------------
            % Decide the parent (axes to plot on)
            %--------------------------------------------------------------
            if isempty(obj.parent)
                
                obj.parent = nb_axes();
                if strcmpi(obj.side,'right')
                    par = obj.parent.plotAxesHandleRight;
                else
                    par = obj.parent.plotAxesHandle;
                end
                
            else
                
                if isa(obj.parent,'nb_axes')
                    
                    if strcmpi(obj.side,'right')
                        par = obj.parent.plotAxesHandleRight;
                    else
                        par = obj.parent.plotAxesHandle;
                    end
                    
                else
                    par = obj.parent;
                end
                
            end
            
            % Start the plotting
            %------------------------------------------------------
            s     = nan(1,sData);
            x     = obj.xData;
            y     = obj.yData;
            for ii = 1:sData
                
                s(ii) = line(x(:,ii),y(:,ii),...
                                'clipping',         'off',...
                                'color',            obj.cData(ii,:),...
                                'lineStyle',        obj.lineStyle,...
                                'lineWidth',        obj.lineWidth,...
                                'marker',           obj.marker{ii},...
                                'markerEdgeColor',  obj.cData(ii,:),...
                                'markerFaceColor',  obj.cData(ii,:),...
                                'markerSize',       obj.markerSize,...
                                'parent',           par,...
                                'visible',          obj.visible);
                
            end
            obj.children = s;

            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')

                % Update the axes given the plotted data
                obj.parent.addChild(obj);

            end
            
        end
        
    end
    
    
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
    
end
