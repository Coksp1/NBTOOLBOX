classdef nb_candle < nb_plotHandle
% Syntax:
%     
% obj = nb_candle(xData,high,low,open,close,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for making bar plots with or without shaded bars.
%  
% nb_candle(xData,high,low,open,close,...
%           'propertyName',propertyValue,...)
% handle = nb_candle(xData,high,low,open,close,...
%                    'propertyName',propertyValue,...)
%   
% The handle have set and get methods as all MATLAB graph handles. 
%     
% Caution: All the children of this object is of class nb_patch and
%          nb_line
%     
% Constructor:
%     
%     obj = nb_candle(xData,high,low,open,close,varargin)
%     
%     Input:
% 
%     - xData     : The xData of the plotted data. Must be of size;
%                   size(high,1) x 1 or 1 x size(high,1)
%                        
%     - high      : The highest observation. Must be a double 
%                   vector. Can be given as a empty double.
%
%     - low       : The lowest observation. Must be a double vector.
%                   Can be given as a empty double.
%
%     - open      : The highest value of the plotted patch. Must be
%                   a double vector. Can be given as a empty double.
%
%     - close     : The lowest value of the plotted patch. Must be
%                   a double vector. Can be given as a empty double.
%
%     - varargin  : ...,'propertyName',propertyValue,...
%     
%     Output
% 
%     - obj      : An object of class nb_candle
%     
%     Examples:
% 
% See also:        
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties(SetAccess=protected)
       
        % All the handles of the bar plot.
        children = [];            
        
    end

    properties
        
        % Width of the candles. Must be a scalar.
        candleWidth           = 0.45;      
        
        % Color of the plotted patches. A matrix; 
        % 1 x 3 (RGB color) or a string with the color 
        % name.
        cData                 = [];  
        
        % The lowest values of the plotted patches, Must 
        % be double vector. Must match the open, high and
        % low properties, if they are not empty.
        close                 = [];
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption          = 'only';
        
        % The direction of the shading; {'north'} | 'south' |
        % 'east' | 'west'
        direction             = 'north';   
        
        % The color of the edge of the bars. In RGB colors
        % or a string with the color names. Can also be  
        % 'none' ; no edgeLine or 'same' ; same color as 
        % the base color for each bar. Can also be a 
        % cellstr with either the RGB colors or color 
        % names with size 1 x size(yData,2).
        edgeColor             = 'same'; 
        
        % The value for where to plot a vertical line.
        % Can be given as an empty double. Must match the 
        % close, open, high and low properties, if they 
        % are not empty.
        indicator             = [];
        
        % The color of the indicator line. As a 1 x 3 
        % double or a string with the color name. Default
        % is [0,0,0].
        indicatorColor        = [0,0,0];
        
        % Sets the indicator line style. Default is '-'.
        indicatorLineStyle    = '-';
        
        % The line width of the indicator line. As a 
        % scalar. Default is 4.
        indicatorLineWidth    = 4;
        
        % The width of the indicator. The default is to
        % use the same width as provided by the 
        % candleWidth property. I.e. when this property
        % is set to [].
        indicatorWidth        = [];
        
        % The highest values of the plotted candles. Must 
        % be double vector. Must match the close, open and
        % low properties, if they are not empty.
        high                  = [];
        
        % The line width of the high and low lines. As 
        % a scalar. Default is 2.
        hlLineWidth           = 2;
        
        % {'off'} : Not included in the legend. 'on' : included in 
        % the legend
        legendInfo            = 'on';      
        
        % Sets the line style(s) of the edge of the bars. 
        % Either a string or a cellstr (which must have 
        % the size 1 x size(yData,2)).
        lineStyle             = '-';
        
        % The line width of the edge of the bars. Must be a scalar.
        lineWidth             = 1;         
        
        % The lowest values of the plotted candles, Must 
        % be double vector. Must match the close, high and
        % open properties, if they are not empty.
        low                   = [];
        
        % Sets the marker of the indicator line. Default
        % is 'none'.
        marker                = 'none';
        
        % The highest values of the plotted patches. Must 
        % be double vector. Must match the close, high and
        % low properties, if they are not empty.
        open                  = [];  
        
        % The color (RGB) the shaded bar plots are 
        % interpolated with. Either a 1x3 double with the
        % RGB colors or a string with the color name.
        % Default is [1,1,1]
        shadeColor            = [1, 1, 1]; 
        
        % Index of which data should be shaded. A vector with size; 
        % size(open,1) x 1 or 1 x size(open,1).
        shaded                = []; 
              
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is of class nb_axes. (Which is the default) 
        side                  = 'left'; 
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'
        visible               = 'on';      
        
        % The xData of the plotted data. Must be of size; 
        % size(high,1) x 1 or 1 x size(high,1)
        xData                 = [];        
          
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        type = 'patch';
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
       function set.candleWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The candleWidth property must be '...
                      'given as a scalar.'])
            end
            obj.candleWidth = value;
       end
       
       function set.cData(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The cData property must'...
                                 ' must have dimension size'...
                                 ' 1 x 3 with the RGB'...
                                 ' colors or a string with with the'...
                                 ' color names.'])
            end
            obj.cData = value;
       end
        
       function set.close(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The close property must be '...
                      'given as a double vector.'])
            end
            obj.close = value;
       end
        
       function set.deleteOption(obj,value)
            if ~nb_isOneLineChar(value) && ~any(ismember({'all','only'},...
                                                                    value))
                error([mfilename ':: The deleteOption property must be'...
                                 ' set to a one line character array.'])
            end
            obj.deleteOption = value;
       end
          
       function set.direction(obj,value)
            if ~any(ismember({'east','south','west','north'},value)) &&...
                                                 ~nb_isOneLineChar(value)
                error([mfilename ':: The direction property must be'...
                                 ' set to a one line character array.'])
            end
            obj.direction = value;
       end 
       
       function set.edgeColor(obj,value)
            if ~nb_isColorProp(value) && ~nb_isOneLineChar(value)
                error([mfilename ':: The edgecolor property must'...
                                 ' must have dimension size'...
                                 ' size(plotData,2) x 3 with the RGB'...
                                 ' colors or a cellstr with size 1 x'...
                                 ' size(yData,2) with the color names.'...
                                 ' Can also be ''none '' or ''same''.'])
            end
            obj.edgeColor = value;
       end 
        
       function set.indicator(obj,value)
            if ~isa(value,'double')
                error([mfilename 'The indicator property must be set '...
                    'to a double.'.'])
            end
            obj.indicator = value;
       end
       
       function set.indicatorColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename 'The indicatorColor property must be set '...
                    'to a 1x3 double or a string with the color name.'])
            end
            obj.indicatorColor = value;
       end
       
       function set.indicatorLineStyle(obj,value)
            if ~nb_islineStyle(value)
                error([mfilename 'The indicatorLineStyle property must be '...
                    'set to a valid line style'])
            end
            obj.indicatorLineStyle = value;
       end
       
       function set.indicatorLineWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename 'The indicatorLineWidth property must be '...
                    'set scalar double.'])
            end
            obj.indicatorLineWidth = value;
       end
       
       function set.indicatorWidth(obj,value)
            if ~nb_isScalarNumber(value) %&& ~isa(value,'double')
                error([mfilename 'The indicatorWidth property must be '...
                    'set scalar double or as an empty double.'])
            end
            obj.indicatorWidth = value;
       end       
       
       function set.high(obj,value)
            if ~isa(value,'double')
                error([mfilename 'The high property must be '...
                    'given as a double vector.'])
            end
            obj.high = value;
       end      
       
       function set.hlLineWidth(obj,value)
            if ~nb_isScalarNumber(value) %&& ~isa(value,'double')
                error([mfilename 'The indicatorWidth property must be '...
                    'set scalar double or as an empty double.'])
            end
            obj.hlLineWidth = value;
       end     
       
       function set.legendInfo(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The legendInfo property must be '...
                      'either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
       end       
       
       function set.lineStyle(obj,value)
            if ~nb_islineStyle(value)
                error([mfilename ':: The lineStyle property must be'...
                      ' a one line char or a cellstring with the line'...
                      ' linestyle with size size(xData,2).'])
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
        
       function set.low(obj,value)
            if ~isa(value,'double')
                error([mfilename 'The low property must be '...
                    'given as a double vector.'])
            end
            obj.low = value;
       end   
       
       function set.marker(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename 'The marker property must be '...
                    'given as a one line character array.'])
            end
            obj.marker = value;
       end
       
       function set.open(obj,value)
            if ~isa(value,'double') && ~isempty(value)
                error([mfilename 'The open property must be '...
                    'given as a double vector'])
            end
            obj.open = value;
       end 
       
       function set.shadeColor(obj,value)
            if ~nb_isColorProp(value) && ~isempty(value)
                error([mfilename 'The open property must be '...
                    'given as a double vector'])
            end
            obj.shadeColor = value;
       end 
       
       function set.shaded(obj,value)
            if ~isa(value,'double') && ~isempty(value)
                error([mfilename 'The shaded property must be '...
                    'given as a double vector'])
            end
            obj.shaded = value;
       end 
       
       function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename '::  The side property must be '...
                      'either ''right'' or ''left'' (default).'])
            end
            obj.side = value;
       end 
       
       function set.visible(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The visible property must be '...
                      'either ''on'' or ''off''.'])
            end
            obj.visible = value;
       end  
       
       function set.xData(obj,value)
            if ~isa(value,'double') && ~isempty(value)
                error([mfilename '::  The xData property must be '...
                      'given as a double.'])
            end
            obj.xData = value;
       end  
       
       
        function obj = nb_candle(xData,high,low,open,close,varargin)
            
            if nargin == 0
                return;
            end
            
            if nargin >= 5
                obj.xData = xData;
                obj.high  = high;
                obj.low   = low;
                obj.open  = open;
                obj.close = close;
            elseif nargin == 4
                obj.xData = xData;
                obj.high  = high;
                obj.low   = low;
                obj.open  = open;
            elseif nargin == 3
                obj.xData = xData;
                obj.high  = high;
                obj.low   = low;
            elseif nargin < 3
                error([mfilename ':: If some inputs is given to the nb_candle constructor, at least three inputs must be given'])
            end
            
            if nargin > 5
                obj.set(varargin);
            else
                % Then just plot
                plotCandles(obj);
            end
            
        end
          
        varargout = get(varargin)
        
        varargout = set(varargin)
        
        function indicatorLineWidth = get.indicatorLineWidth(obj)
            
           indicatorLineWidth = nb_scaleLineWidth(obj,obj.indicatorLineWidth); 
            
        end
        
        function hlLineWidth = get.hlLineWidth(obj)
            
           hlLineWidth = nb_scaleLineWidth(obj,obj.hlLineWidth); 
            
        end
        
        function lineWidth = get.lineWidth(obj)
            
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
            
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
            
            % Delete all the children of the object 
            for ii = 1:size(obj.children,2)
               
                if isvalid(obj.children{ii})
                    
                    % Set the delete option for the children
                    obj.children{ii}.deleteOption = obj.deleteOption;
                    
                    % Then delete
                    delete(obj.children{ii})
                    
                end
                
            end
             
        end
        
        %{
        -------------------------------------------------------------------
        Find the x-axis limits of this object
        -------------------------------------------------------------------
        %}
        function xlimit = findXLimits(obj)
        
            xlimit    = [min(obj.xData),max(obj.xData)];
            xlimit(1) = xlimit(1) - 0.5;
            xlimit(2) = xlimit(2) + 0.5;
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
            
            if ~isempty(obj.high)
                dataHigh = obj.high;
            else
                dataHigh = obj.open;
            end
            if ~isempty(obj.low)
                dataLow = obj.low;
            else
                dataLow = obj.close;
            end
                
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
            for ii = 1:size(obj.children,2)
                
                obj.children{ii}.setVisible();
                
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
            
            legendDetails = nb_legendDetails();
            if strcmpi(obj.legendInfo,'on')
                
                legendDetails.patchColor             = obj.cData;
                legendDetails.patchDirection         = obj.direction;
                legendDetails.patchEdgeColor         = obj.edgeColor;
                legendDetails.patchEdgeLineStyle     = obj.lineStyle;
                legendDetails.patchEdgeLineWidth     = obj.lineWidth;
                legendDetails.type                   = 'patch';
                     
            end
            
        end
  
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        The method which does the plotting
        -------------------------------------------------------------------
        %}
        function plotCandles(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                for ii = 1:length(obj.children)
                    if isvalid(obj.children{ii})
                        obj.children{ii}.deleteOption = 'all';
                        delete(obj.children{ii});
                    end
                end
                obj.children = [];
            end
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if isempty(obj.xData)
                error([mfilename ':: The xData property cannot be empty'])
            end
            
            if size(obj.xData,1) == 1
                obj.xData = obj.xData';
            end
            
            if size(obj.xData,2) > 1
                error([mfilename ':: The ''xData'' property must be a vector, but is a matrix with size; '...
                                 int2str(size(obj.xData,1)) 'x' int2str(size(obj.xData,2))])
            end
            
            if size(obj.high,1) == 1
                obj.high = obj.high';
            end
            
            if size(obj.high,2) > 1
                error([mfilename ':: The ''high'' property must be a vector, but is a matrix with size; '...
                                  int2str(size(obj.high,1)) 'x' int2str(size(obj.high,2))])
            end
            
            if size(obj.low,1) == 1
                obj.low = obj.low';
            end
            
            if size(obj.low,2) > 1
                error([mfilename ':: The ''low'' property must be a vector, but is a matrix with size; '...
                                  int2str(size(obj.low,1)) 'x' int2str(size(obj.low,2))])
            end
            
            if size(obj.open,1) == 1
                obj.open = obj.open';
            end
            
            if size(obj.open,2) > 1
                error([mfilename ':: The ''open'' property must be a vector, but is a matrix with size; '...
                                  int2str(size(obj.open,1)) 'x' int2str(size(obj.open,2))])
            end
            
            if size(obj.close,1) == 1
                obj.close = obj.close';
            end
            
            if size(obj.close,2) > 1
                error([mfilename ':: The ''close'' property must be a vector, but is a matrix with size; '...
                                  int2str(size(obj.close,1)) 'x' int2str(size(obj.close,2))])
            end
            
            if isempty(obj.cData)
                
                obj.cData = nb_plotHandle.getDefaultColors(1);
                
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,2) ~= 3
                    error([mfilename ':: The ''cData'' property must be a Mx3 matrix with the rgb colors of the plotted data.'])
                elseif size(obj.cData,1) ~= 1
                    error([mfilename ':: The ''cData'' property must have 1 row when given as a double.'])
                end
                
            elseif iscellstr(obj.cData)
                
                if length(obj.cData) ~= 1
                    error([mfilename ':: The cellstr array given by ''cData'' property has more elements then 1'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            elseif ischar(obj.cData)
                
                if size(obj.cData,1) ~= 1
                    error([mfilename ':: The char given by ''cData'' property has more rows then 1.'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            else
                
                error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])    
                
            end
            
            if isempty(obj.shaded)
                obj.shaded = zeros(size(obj.xData));
            end
            
            if size(obj.shaded,1) == 1
                obj.shaded = obj.shaded';
            end
            
            if size(obj.shaded,2) ~= 1
                error([mfilename ':: The ''shaded'' property must be a double vector.'])
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
            
            %--------------------------------------------------------------
            % Start plotting
            %--------------------------------------------------------------
            try
                s  = size(obj.xData,1);
                p  = cell(s,1);
                if isempty(obj.open) && isempty(obj.close)
                    plotC = 0;
                    
                    if isempty(obj.low) || isempty(obj.high)
                        error([mfilename ':: If the properties open and close is empty, then high and low cannot be.'])
                    else
                        l = obj.low + (obj.high - obj.low)/2;
                        h = obj.low + (obj.high - obj.low)/2;
                    end
                    
                elseif isempty(obj.close)
                    l    = obj.open;
                    h    = obj.open;
                    plotC = 1;
                elseif isempty(obj.open)
                    l    = obj.close;
                    h    = obj.close;
                    plotC = 1;
                else
                    l    = obj.close;
                    h    = obj.open;
                    plotC = 1;
                end
                
                % Plot the lower vertical line of the candle
                %--------------------------------------------------
                l1 = cell(s,1);
                if isempty(obj.low)
                    plot = 0;
                else
                    plot = 1;
                end
                
                if plot 
                    
                    for ii = 1:s
                        
                        xx     = [obj.xData(ii), obj.xData(ii)];
                        start  = l(ii);
                        finish = obj.low(ii);
                        yy     = [start, finish];
                        l1{ii} = nb_line(xx,yy,...
                                      'clipping',         'off',...
                                      'cData',            [0,0,0],...
                                      'legendInfo',       'off',...
                                      'lineWidth',        obj.hlLineWidth,...
                                      'parent',           par,...
                                      'visible',          obj.visible);
                        
                        
                    end
                    
                    obj.children = [obj.children, l1];
                    
                end
                
                % Plot the lower horizontal line of the candle
                %--------------------------------------------------
                l2 = cell(s,1);
                if isempty(obj.low)
                    plot = 0;
                else
                    plot = 1;
                end
                
                if plot 
                    
                    for ii = 1:s
                        
                        x      = obj.xData(ii);
                        cw     = obj.candleWidth/2;
                        xx     = [x - cw; x + cw];
                        lowest = obj.low(ii);
                        yy     = [lowest, lowest];
                        l2{ii} = nb_line(xx,yy,...
                                      'clipping',         'off',...
                                      'cData',            [0,0,0],...
                                      'legendInfo',       'off',...
                                      'lineWidth',        obj.hlLineWidth,...
                                      'parent',           par,...
                                      'visible',          obj.visible);
                        
                        
                    end
                    
                    obj.children = [obj.children, l2];
                    
                end
                
                % Plot the higher vertical line of the candle
                %--------------------------------------------------
                l3 = cell(s,1);
                if isempty(obj.high)
                    plot = 0;
                else
                    plot = 1;
                end
                
                if plot 
                    
                    for ii = 1:s
                        
                        xx     = [obj.xData(ii), obj.xData(ii)];
                        start  = h(ii);
                        finish = obj.high(ii);
                        yy     = [start, finish];
                        l3{ii} = nb_line(xx,yy,...
                                      'clipping',         'off',...
                                      'cData',            [0,0,0],...
                                      'legendInfo',       'off',...
                                      'lineWidth',        obj.hlLineWidth,...
                                      'parent',           par,...
                                      'visible',          obj.visible);
                        
                        
                    end
                    
                    obj.children = [obj.children, l3];
                    
                end
                
                % Plot the higher horizontal line of the candle
                %--------------------------------------------------
                l4 = cell(s,1);
                if isempty(obj.high)
                    plot = 0;
                else
                    plot = 1;
                end
                
                if plot 
                    
                    for ii = 1:s
                        
                        x       = obj.xData(ii);
                        cw      = obj.candleWidth/2;
                        xx      = [x - cw; x + cw];
                        highest = obj.high(ii);
                        yy      = [highest, highest];
                        l4{ii}  = nb_line(xx,yy,...
                                      'clipping',         'off',...
                                      'cData',            [0,0,0],...
                                      'legendInfo',       'off',...
                                      'lineWidth',        obj.hlLineWidth,...
                                      'parent',           par,...
                                      'visible',          obj.visible);
                        
                        
                    end
                    
                    obj.children = [obj.children, l4];
                    
                end
                
                % Plot the patch of the candle
                %--------------------------------------------------
                if plotC
                    
                    for ii = 1:s

                        % Color specification
                        if obj.shaded(ii)
                            colorTemp = [obj.cData; obj.shadeColor];
                        else
                            colorTemp = obj.cData;
                        end

                        % Patch coordinates
                        x     = obj.xData(ii);
                        cw    = obj.candleWidth/2;
                        x     = [x - cw; x - cw; x + cw; x + cw];
                        y     = [l(ii) ; h(ii) ; h(ii) ; l(ii)];
                        p{ii} = nb_patch(x,y,colorTemp,...
                                     'parent',      par,...
                                     'lineWidth',   obj.lineWidth,...
                                     'lineStyle',   obj.lineStyle,...
                                     'direction',   obj.direction,...
                                     'edgeColor',   obj.edgeColor,...
                                     'legendInfo',  'off',...
                                     'visible',     obj.visible,...
                                     'side',        obj.side);

                    end
                
                    obj.children = [obj.children, p];  
                    
                end
                
                % Plot the indicator line of the candle
                %--------------------------------------------------
                l5 = cell(s,1);
                l6 = {};
                if isempty(obj.indicator)
                    plot = 0;
                else
                    plot = 1;
                end
                
                if plot 
                    
                    if ischar(obj.indicatorColor)
                        obj.indicatorColor = nb_plotHandle.interpretColor(obj.indicatorColor);
                    end
                    
                    for ii = 1:s
                        
                        x      = obj.xData(ii);
                        if isempty(obj.indicatorWidth)
                            cw = obj.candleWidth/2;
                        else
                            cw = obj.indicatorWidth/2;
                        end
                        xx     = [x - cw; x + cw];
                        yy     = obj.indicator(ii);
                        yy     = [yy, yy]; %#ok
                        l5{ii} = nb_line(xx,yy,...
                                      'clipping',         'off',...
                                      'cData',            obj.indicatorColor,...
                                      'legendInfo',       'off',...
                                      'lineStyle',        obj.indicatorLineStyle,...
                                      'lineWidth',        obj.indicatorLineWidth,...
                                      'parent',           par,...
                                      'visible',          obj.visible);
                          
                    end
                    
                    if ~strcmpi(obj.marker,'none')
                         
                        l6 = cell(s,1);
                        for ii = 1:s
                        
                            x      = obj.xData(ii);
                            xx     = [x; x];
                            yy     = obj.indicator(ii);
                            yy     = [yy, yy]; %#ok
                            l6{ii} = nb_line(xx,yy,...
                                          'clipping',         'off',...
                                          'cData',            obj.indicatorColor,...
                                          'legendInfo',       'off',...
                                          'lineStyle',        'none',...
                                          'marker',           obj.marker,...
                                          'markerEdgeColor',  'auto',...
                                          'markerFaceColor',  'auto',...
                                          'parent',           par,...
                                          'visible',          obj.visible);

                        end
                             
                    end
                    
                    obj.children = [obj.children, l5];
                    
                    if ~isempty(l6)
                        
                        obj.children = [obj.children, l6];
                        
                    end
                    
                end
                
            catch Err
                
                if ~isempty(obj.children)
                    for ii = 1:length(obj.children)
                        obj.children{ii}.deleteOption = 'all';
                    end
                    obj.children = [];
                end
                
                % Rethrow the error message
                rethrow(Err);
                
            end
            
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
    % Static methods
    %======================================================================
    methods (Static=true)
       
           
    end
    
end
        
