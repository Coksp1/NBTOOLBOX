classdef nb_plot < nb_plotHandle & nb_notifiesMouseOverObject
% Syntax:
%     
% obj = nb_plot(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is A class for plotting data by lines (2D). Much the same as 
% the MATLAB plot function, but with some extensions (and some 
% limitiation)
% 
% Extended functionalitites:
%     - New line style added '---'. Longer dashed of the dashed 
%       line
%     - Choose the linestyle of all the plotted lines. By a cell.
%     - Choose the linecolor of all the plotted lines directly to 
%       the class, and not through the default options. By a mx3 
%       double with the RGB colors of the m lines
%     - Makes it possible to set a nb_axes handle as parent 
%       (default). Which makes the plot nicer. It is also possible 
%       to add shaded background. See nb_axes for more.
%     
% Constructor:
%     
%     nb_plot(yData)
%     nb_plot(xData,yData)  
%     nb_plot(xData,yData,'propertyName',propertyValue,...)
%     handle = nb_plot(xData,yData,'propertyName',propertyValue,...)  
%    
%     Input:
% 
%     - xData : The x-axis values of the plotted line. If only one 
%               input is given to this constructor it will be 
%               interpreted as the yData input. (Then the xData 
%               will be 1:size(yData,1))
% 
%     - yData : The y-axis values of the plotted line. A double
%               matrix. (1. dimension the number of observations 
%               and 2. dimension the number of variables.)
% 
%     Optional input:
% 
%     - varargin : 'propertyName',propertyValue,...
% 
%     Output:
% 
%     - obj : An object of class nb_plot
%     
%     Examples:    
% 
%     nb_plot([0,2]);
% 
%         same as 
% 
%     nb_plot([0,1],[0,2;2,3]);
% 
%     nb_plot([0,1],[0,2],'propertyName',propertyValue,...);
% 
%     e.g.
% 
%     nb_plot([0,1],[0,2;2,3],'cData',{'red','green'},...
%             'lineWidth',1.5);   
% 
%     Return the handle to the plotted line:
% 
%     l = nb_plot([0,1],[0,2;2,3],'cData',{'red','green'},...
%                 'lineWidth',1.5); 
% 
%     Which you can use to set and get properties:
% 
%     l.set('cData',{'black','red'});
%     lw = l.get('lineWidth');      
%     
% See also:
% plot
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties(SetAccess = protected)

        % The children of the handle. As nb_line handles
        children = []; 
        
    end

    properties
        
        % The color data of the line plotted. Must be 
        % of size; size(yData,2) x 3. With the RGB 
        % colors. or a cellstr with the color names.  
        % See the method interpretColor of the 
        % nb_plotHandle class for more on the 
        % supported color names. 
        cData               = [];           
              
        % {'on'} | 'off' ; Clipping mode. MATLAB clips
        % lines to the axes plot box by default. If you
        % set Clipping to off, lines are displayed 
        % outside the axes plot box. 
        clipping            = 'on';         
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.  
        deleteOption        = 'only'; 
        
        % {'off'} : Not included in the legend. 'on' : 
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
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'
        visible             = 'on'; 
        
        % The x-axis data. As a double.
        xData               = [];  
        
        % The y-axis data. As a double.
        yData               = [];           
        
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
                error([mfilename '::  The clipping property must be'...
                    ' either ''on'' or ''off''.'])
            end
            obj.clipping = value;
        end
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.legendInfo(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The legendInfo property must be '...
                      'either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
        end          
        
        function set.lineStyle(obj,value)
            if ~nb_islineStyle(value,1)
                error([mfilename ':: The lineStyle property must be'...
                      ' a one line char or a cellstring with the line'...
                      ' linestyle with size size(xData,2).'])
            end
            obj.lineStyle = value;
        end
        
        function set.lineWidth(obj,value)
            if ~(1==size(value,1))
                error([mfilename ':: The lineWidth property must be'...
                                 ' set to a scalar double.'])
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
            if ~nb_isColorProp(value) 
                error([mfilename ':: The markerEdgeColor property must'...
                                 ' must have dimension size'...
                                 ' 1 x 3 with the RGB colors'...
                                 ' or a one line character array with'...
                                 ' ''none'' or ''auto''.'])
            end
            obj.markerEdgeColor = value;
        end

        function set.markerFaceColor(obj,value)
            if ~nb_isColorProp(value,1) && ~any(strcmp({'none','auto'},value))
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
                error([mfilename ':: The markerSize property must be set '...
                      'to a scalar double.'])
            end
            obj.markerSize = value;
        end      
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename '::  The side property must be set to '...
                      'either ''left'' or ''right''.'])
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
            if ~any(ismember(size(value),1)) && ~isa(value,'double')
                error([mfilename ':: The xData property must be'...
                                 ' of size; size(yData,1) x 1 or'...
                                 ' 1 x size(yData,1).'])
            end
            obj.xData = value;
        end
        
        function set.yData(obj,value)
            if ~any(ismember(size(value),1)) && ~isa(value,'double')
                error([mfilename ':: The yData property must be'...
                                 ' of size; size(yData,1) x 1 or'...
                                 ' 1 x size(yData,1).'])
            end
            obj.yData = value;
        end        
        
        function obj = nb_plot(xData,yData,varargin)
            
            if nargin == 1
                
                obj.yData = xData;
                obj.xData = 1:length(xData);
                
                % Then just plot
                plotLines(obj);
                
            elseif nargin > 1
                
                if ~isnumeric(yData)
                    obj.yData = xData;
                    obj.xData = 1:size(xData,1);
                    varargin  = [yData,varargin];
                else
                    obj.xData = xData;
                    obj.yData = yData;
                end
                
                if nargin > 2
                    obj.set(varargin);
                else
                    % Then just plot
                    plotLines(obj);
                end
                
            end
            
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

            if isa(obj,'nb_plotBarAtEnd')
                return
            end
            
            % Remove it form its parent
            if isa(obj.parent,'nb_axes')
                if isvalid(obj.parent)
                    obj.parent.removeChild(obj);
                end
            end

            % Delete all the children of the object 
            if isa(obj.children,'nb_line')
                for ii = 1:size(obj.children,2)
                    if isvalid(obj.children(ii))
                        obj.children(ii).deleteOption = obj.deleteOption;
                        delete(obj.children(ii))
                    end
                end
            else
                for ii = 1:size(obj.children,2)
                    if ishandle(obj.children(ii))
                        if strcmpi(obj.deleteOption,'all')
                            delete(obj.children(ii))
                        end
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
            
            if isempty(dataHigh)
                ylimit = [0,1];
            else
                ylimit = nb_plotHandle.findLimitsAlgo(dataLow,dataHigh,method,fig);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the visible property of this handle and all the children 
        (Without replotting) This method should only be called from the 
        parent, when its visible property is set to 'off'
        -------------------------------------------------------------------
        %}
        function setVisible(obj)
            
            obj.visible = get(obj.parent,'visible');
            if isa(obj.children,'nb_line')
                for ii = 1:size(obj.children,2)
                    obj.children(ii).setVisible();
                end
            else
                for ii = 1:size(obj.children,2)
                    set(obj.children(ii),'visible',obj.visible);
                end
            end
            
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
            
            if strcmpi(obj.legendInfo,'on')
                % Loop through the children (nb_patch objects)
                if isa(obj.children,'nb_line')
                    legendDetails(1,size(obj.children,2)) = nb_legendDetails();
                    for ii = 1:size(obj.children,2)
                       legendDetails(ii) = getLegendInfo(obj.children(ii)); 
                    end
                else
                    
                    legendDetails(1,size(obj.children,2)) = nb_legendDetails();
                    for ii = 1:size(obj.children,2)
                        legendDetails(ii).lineColor            = obj.cData(ii,:);             
                        legendDetails(ii).lineStyle            = get(obj.children(ii),'lineStyle');
                        legendDetails(ii).lineWidth            = get(obj.children(ii),'lineWidth');
                        legendDetails(ii).lineMarker           = get(obj.children(ii),'marker');
                        legendDetails(ii).lineMarkerEdgeColor  = obj.markerEdgeColor;
                        legendDetails(ii).lineMarkerFaceColor  = obj.markerFaceColor;
                        legendDetails(ii).lineMarkerSize       = obj.markerSize;
                        legendDetails(ii).side                 = obj.side;
                    end
                    
                end
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the nb_plot object. E.g. when you have set properties
        outside the set method.
        -------------------------------------------------------------------
        %}
        function update(obj)
           
            plotLines(obj);
            
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
            distances = (xDataNormal - xPointer) .^ 2 + (yDataNormal - yPointer) .^ 2;
            [closestDistance, ind] = min(distances(:));
            closestDistance        = sqrt(closestDistance);
            [x, y]                 = ind2sub(size(distances), ind);

            threshold = 0.015; 
            if closestDistance < threshold
                value = [obj.xData(x),obj.yData(x, y)];
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
        
        %{
        -------------------------------------------------------------------
        Plot the lines
        -------------------------------------------------------------------
        %}
        function plotLines(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                for ii = 1:length(obj.children)
                    obj.children(ii).deleteOption = 'all';
                    delete(obj.children(ii));
                end
                obj.children = [];
            end
            
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
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,1) == 1
                obj.xData = obj.xData';
            end
            
            if size(obj.yData,1) == 1 && size(obj.xData,1) ~= 1
                obj.yData = obj.yData';
            end
            
            if size(obj.xData,1) ~= size(obj.yData,1)
                error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same number of rows.'])
            end
            
            if size(obj.xData,2) ~= size(obj.yData,2)
                
                if size(obj.xData,2) == 1
                    obj.xData = repmat(obj.xData,[1,size(obj.yData,2)]);
                else
                    error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same number of columns.'])
                end
            end
            
            if isempty(obj.cData)
                
                % Get the default color(s)
                obj.cData = nb_plotHandle.getDefaultColors(size(obj.yData,2));
                
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,2) ~= 3
                    error([mfilename ':: The ''cData'' property must be a Mx3 matrix with the rgb colors of the plotted data.'])
                elseif size(obj.cData,1) ~= size(obj.yData,2)
                    error([mfilename ':: The ''cData'' property has not as many rows (' int2str(size(obj.cData,1)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
                end
                
            elseif iscell(obj.cData)
                
                if length(obj.cData) ~= size(obj.yData,2)
                    error([mfilename ':: The cellstr array given by ''cData'' property has not same length (' int2str(length(obj.cData)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            elseif ischar(obj.cData)
                
                if size(obj.cData,1) ~= size(obj.yData,2)
                    error([mfilename ':: The char given by ''cData'' property has not same number of rows (' int2str(size(obj.cData,1)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            else
                
                error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])       
                
            end
            
            %--------------------------------------------------------------
            % I need to find the axes limits
            %--------------------------------------------------------------
            if find(strcmp('---',obj.lineStyle),1)
                
                xLim = findXLimits(obj);
                yLim = findYLimits(obj);
                
                if ~isempty(get(obj.parent,'children'))
                    
                    yLimAxes = get(obj.parent,'yLim');
                    xLimAxes = get(obj.parent,'xLim');
                    
                    xLim = [min([xLim(1),xLimAxes(1)]), max([xLim(2),xLimAxes(2)])];
                    yLim = [min([yLim(1),yLimAxes(1)]), max([yLim(2),yLimAxes(2)])];

                end
                
            else 
                xLim = [];
                yLim = [];
            end
            
            if isscalar(obj.lineWidth)
                lineW = repmat(obj.lineWidth,[1, size(obj.yData,2)]);
            else
                if length(obj.lineWidth) ~= size(obj.yData,2)
                    error([mfilename ':: The ''lineWidth'' property has not the same length (' int2str(length(obj.lineWidth)) ') '...
                                     'as the ''yData'' property (' int2str(size(obj.yData,2)) ').']);            
                else
                    lineW = obj.lineWidth;
                end
            end
            
            %--------------------------------------------------------------
            % Start the plotting
            %--------------------------------------------------------------
            x  = obj.xData;
            y  = obj.yData;
            c  = obj.cData;
            ma = obj.marker;
            ls = obj.lineStyle;
            if ~iscellstr(ma)
                ma = {ma};
                ma = ma(1,ones(1,size(y,2)));
            end
            if ~iscellstr(ls)
                ls = {ls};
                ls = ls(1,ones(1,size(y,2)));
            end
            
            if any(strcmpi('---',ls))
                
                ch(1,size(y,2)) = nb_line();
                for ii = 1:size(y,2)

                    ch(ii).xData           = x(:,ii); %#ok<*AGROW>
                    ch(ii).yData           = y(:,ii);
                    ch(ii).clipping        = obj.clipping;
                    ch(ii).cData           = c(ii,:);
                    ch(ii).legendInfo      = obj.legendInfo;
                    ch(ii).lineStyle       = ls{ii};
                    ch(ii).lineWidth       = lineW(ii);
                    ch(ii).marker          = ma{ii};
                    ch(ii).markerEdgeColor = obj.markerEdgeColor;
                    ch(ii).markerFaceColor = obj.markerFaceColor;
                    ch(ii).markerSize      = obj.markerSize;
                    ch(ii).parent          = axh;
                    ch(ii).side            = obj.side;
                    ch(ii).visible         = obj.visible;
                    ch(ii).xLim            = xLim;
                    ch(ii).yLim            = yLim;
                    ch(ii).update();

                end
                
            else
                
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
                
                ch = nb_gobjects(1,size(y,2));
                for ii = 1:size(y,2)

                    if strcmpi(obj.markerFaceColor,'auto')
                        mFaceColor = c(ii,:);
                    else
                        mFaceColor = obj.markerFaceColor;
                    end
                    
                    ch(ii) = line(x(:,ii),y(:,ii),...
                    'clipping',         obj.clipping,...
                    'color',            c(ii,:),...
                    'lineStyle',        ls{ii},...
                    'lineWidth',        lineW(ii),...
                    'marker',           ma{ii},...
                    'markerEdgeColor',  obj.markerEdgeColor,...
                    'markerFaceColor',  mFaceColor,...
                    'markerSize',       obj.markerSize,...
                    'parent',           axh,...
                    'visible',          obj.visible);

                    if strcmpi(obj.legendInfo,'off')
                        set(get(get(ch(ii),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); 
                    end 
                
                end
                
            end
                
            obj.children = ch;
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                % Update the axes given the plotted data
                obj.parent.addChild(obj);
            end
            
        end
        
    end
    
end
