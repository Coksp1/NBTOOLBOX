classdef nb_plotComb < nb_plotHandle & nb_notifiesMouseOverObject
% Syntax:
%     
% obj = nb_plotComb(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for plotting data with different plot types
%     
% The plotypes supported by this function are:
%    
% - 'area'    : Uses the nb_area class
%     
% - 'line'    : Uses the nb_plot class
%     
% - 'grouped' : Uses the nb_bar class, with the property style
%               set to 'grouped'
%     
% - 'stacked' : Uses the nb_bar class, with the property style
%               set to 'stacked'
%     
% Constructor:
%     
%     obj = nb_plotComb(xData,yData,varargin)
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
%     - obj      : An object of class nb_plotComb (handle).
%     
%     Examples:
% 
%     nb_plotComb([0,2]);
% 
%         same as 
% 
%     nb_plotComb([0,1],[0,2;2,3]);
% 
%     nb_plotComb([0,1],[0,2],'propertyName',propertyValue,...);
% 
%     e.g.
% 
%     nb_plotComb([0,1],[0,2;2,3],'types',{'area','line'},...
%             'lineWidth',1.5);   
% 
%     Return the handle to the plotted line:
% 
%     l = nb_plotComb([0,1],[0,2;2,3],'types',{'area','line'},...
%                 'lineWidth',1.5); 
% 
%     Which you can use to set and get properties:
% 
%     l.set('cData',{'black','red'});
%     lw = l.get('lineWidth');      
%     
% Written by Kenneth Sæterhagen Paulsen
  
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties(SetAccess=protected)
        
        % The children of the handle. As nb_plot, nb_bar and 
        % nb_area handles (objects)
        children = {};      
        
    end
    
    properties
       
        % Sets the alpha blending parameter nr 1 when blend is set to
        % true.
        alpha1                = 0.5;
        
        % Sets the alpha blending parameter nr 1 when blend is set to
        % true.
        alpha2                = 0.5;
        
        % Set this property to true to make the areas abruptly 
        % finish when given as nan.
        abrupt                = false;
        
        % Width of the bars. As a scalar. 0.45 is 
        % default.
        barWidth              = 0.45; 
        
        % A nb_horizontalLine handle (object). Use the set and get 
        % methods of this handle to change the baseline properties.
        %
        % Caution: If baseValue is a vector this property is a nb_line
        %          object.
        baseline              = [];    
        
        % The base value of the plot. Must be a scalar or a vector with 
        % size size(yData,1) x 1. The last option is not supported if any
        % of the variables are plot as area!
        baseValue             = 0;
        
        % When shaded is used, and this option is set to true, it will do
        % alpha blending with shadeColor instead of shading.
        blend                 = false;
        
        % The color data of the line plotted. Must be 
        % of size; size(yData,2) x 3 with the RGB 
        % colors or a cellstr with size 1 x 
        % size(yData,2) with the color names.
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
        
        % The direction of the shading; {'north'} | 
        % 'south' | 'east' | 'west' (Only bar plot)
        direction           = 'north';      
        
        % The color of the edge of the bars. In RGB 
        % colors | 'none' : No edgeLine | 'same' : Same
        % color as the base color for each bar |
        % a string with the color name.
        edgeColor           = 'same'; 
        
        % Line style of the edge of area and bar plots.
        edgeLineStyle       = '-';    
        
        % Line width of the edge of area and bar plots.
        edgeLineWidth       = 1;            
        
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
        
        % Size of the markers. Must be an integer. Default is 9.
        markerSize          = 9;
             
        % The color the shaded bar plots are interpolated with.
        % A 1x3 double with the RGB colors | 'none' | {'auto'}
        % | a string with the color name.
        shadeColor          = [1, 1, 1];    
        
        % Index of which data should be shaded. A 
        % matrix with size; size(yData,1) x 1 , 
        % 1 x size(yData,1) or size(yData,1) x number 
        % of variables to be plotted as bars
        shaded              = [];           
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default) 
        side                = 'left';   
        
        % A cell array of the plot type of each column of the 
        % property 'yData'. Must have same size as size(yData,2).
        % Supported types : 'line','grouped','stacked' and 'area'.
        types               = {}; 
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'.
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
        
        indexArea     =  [];
        indexGrouped  =  [];
        indexLine     =  [];
        indexStacked  =  []; 
        type          =  'both';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
       function set.abrupt(obj,value)
            if isnumeric(value) || islogical(value)
                if ~ismember(value,[0,1])
                    error([mfilename ':: The abrupt property must be'...
                                 ' set to a logical.'])
                end
            else
                error([mfilename ':: The abrupt property must be'...
                                 ' set to a logical.'])
            end
            obj.abrupt = logical(value);
       end
        
       function set.barWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The barWidth property must be'...
                                 ' set to a logical.'])
            end
            obj.barWidth = value;
       end
        
       function set.baseline(obj,value)
            if ~isa(value,'nb_horizontalLine') && ~isa(value,'nb_line')
                error([mfilename ':: The baseline property must be'...
                                 ' set to an nb_horizontalLine handle'...
                                 ' (object).'])
            end
            obj.baseline = value;
       end
        
        function set.baseValue(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The baseValue property must be'...
                                 ' set to a scalar value or as a vector'...
                                 ' of size size(yData,1) x 1'])
            end
            obj.baseValue = value;
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
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename ':: The deleteOption property must be'...
                                 ' set to either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.direction(obj,value)
            if ~any(strcmp({'south','west','north','south'},value))
                error([mfilename ':: The direction property must be'...
                                 ' set to either ''south'', ''east'','...
                                 ' ''west'', or north.'])
            end
            obj.direction = value;
        end
        
        function set.edgeColor(obj,value)
            if ~any(strcmp({'none','same'},value))
                error([mfilename ':: The edgeColor property must be'...
                                 ' set to either ''none'' or ''same''.'])
            end
            obj.edgeColor = value;
        end
        
        function set.edgeLineStyle(obj,value)
            if ~nb_islineStyle(value)
                error([mfilename ':: The edgeLineStyle property must be'...
                                 ' given as a valid line style.'])
            end
            obj.edgeLineStyle = value;
        end
        
        function set.edgeLineWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The edgeLineWidth property must be'...
                                 ' given as a scalar double..'])
            end
            obj.edgeLineWidth = value;
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
                                 ' given as a valid line style.'])
            end
            obj.lineStyle = value;
        end
        
        function set.lineWidth(obj,value)
            if ~isnumeric(value)
                error([mfilename ':: The lineWidth property must be'...
                                 ' given as a scalar double.'])
            end
            obj.lineWidth = value;
        end
        
        function set.marker(obj,value)
            if ~nb_ismarker(value,1)
                error([mfilename ':: The marker property must be given '...
                    'as either a one line character array or a cell '...
                    'array.'])
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
            if ~nb_isColorProp(value,1) 
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
        
        function set.shadeColor(obj,value)
            if ~nb_isColorProp(value,1) 
                error([mfilename ':: The shadeColor property must'...
                                 ' must have dimension size'...
                                 ' 1 x 3 with the RGB colors'...
                                 ' or a one line character array with'...
                                 ' ''none'' or ''auto''.'])
            end
            obj.shadeColor = value;
        end       
        
        function set.shaded(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The shaded property must be'...
                                 ' given as a double.'])
            end
            obj.shaded = value;
        end   
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename ':: The side property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.side = value;
        end    
        
        function set.types(obj,value)
            if ~nb_istype(value,1)
                error([mfilename ':: The types property must be'...
                                 ' set to either ''line'', ''grouped'','...
                                 ' ''stacked'', or ''area'''])
            end
            obj.types = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The visible property must be'...
                                 ' set to either ''left'' or ''right''.'])
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
        
        function set.yData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.yData = value;
        end                    
   
        
        function obj = nb_plotComb(xData,yData,varargin)
            
            if nargin < 2
                
                if nargin == 1
                    obj.yData = xData;
                    obj.xData = 1:size(xData,1);
                else
                    obj.xData = [0; 1];
                    obj.yData = [0; 1];
                end
                
            else
                
                if ~isnumeric(yData)
                    obj.yData = xData;
                    obj.xData = 1:size(xData,1);
                    varargin  = [yData,varargin];
                else
                    obj.xData = xData;
                    obj.yData = yData;
                end
                
            end
            
            if nargin > 2
                obj.set(varargin);
            else
                % Then just plot
                plotTypes(obj);
            end
            
        end

        varargout = set(varargin)
        
        varargout = get(varargin)
        
        function edgeLineWidth = get.edgeLineWidth(obj)
           edgeLineWidth = nb_scaleLineWidth(obj,obj.edgeLineWidth); 
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
        
            xlimit = [min(min(obj.xData)),max(max(obj.xData))];
            if sum(obj.indexStacked) ~= 0 || sum(obj.indexGrouped) ~= 0
                xlimit = [xlimit(1) - 0.5, xlimit(2) + 0.5];   
            end
            
        end
            
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
            
            dataLow  = [];
            dataHigh = [];
            
            dataStacked = obj.yData(:,logical(obj.indexArea + obj.indexStacked));
            if ~isempty(dataStacked) 
            
                upos = zeros(size(dataStacked));
                uneg = upos;
                if isscalar(obj.baseValue)
                    baseV      = obj.baseValue;
                    ipos       = dataStacked >= baseV;
                    ineg       = dataStacked < baseV;
                    upos(ipos) = dataStacked(ipos) - baseV;
                    uneg(ineg) = dataStacked(ineg) - baseV;
                else
                    baseV      = obj.baseValue(:,ones(1,size(dataStacked,2)));
                    ipos       = dataStacked >= baseV;
                    ineg       = dataStacked < baseV;
                    upos(ipos) = dataStacked(ipos) - baseV(ipos);
                    uneg(ineg) = dataStacked(ineg) - baseV(ineg);
                end
                dataLow    = sum(uneg,2) + obj.baseValue;
                dataHigh   = sum(upos,2) + obj.baseValue;
               
            end 
            
            dataNotStacked = obj.yData(:,logical(obj.indexLine + obj.indexGrouped));
            if ~isempty(dataNotStacked)
                if isempty(dataHigh)
                    dataLow  = dataNotStacked;
                    dataHigh = dataNotStacked;
                else
                    dataLow  = [dataNotStacked, dataLow];
                    dataHigh = [dataNotStacked, dataHigh];
                end
            end
            
            % Need to add the base value, so it is included in the plot,
            % except when all the data is plotted as lines
            if sum(obj.indexArea + obj.indexStacked + obj.indexGrouped) ~= 0
                if isscalar(obj.baseValue)
                    baseValues = ones(size(obj.yData,1),1)*obj.baseValue;
                else
                    baseValues = obj.baseValue;
                end
                dataLow    = [dataLow,  baseValues];
                dataHigh   = [dataHigh, baseValues];
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
            
            if strcmpi(obj.legendInfo,'on')
                
                ind = 1;
                
                if sum(obj.indexArea,2) == 0
                    legendDetailsA = [];
                else
                    legendDetailsA = getLegendInfo(obj.children{ind});
                    ind = ind + 1; 
                end
                
                if sum(obj.indexGrouped + obj.indexStacked,2) == 0
                    legendDetailsB = [];
                else
                    legendDetailsB = getLegendInfo(obj.children{ind});
                    ind = ind + 1; 
                end
                
                if sum(obj.indexLine,2) == 0
                    legendDetailsP = [];
                else
                    legendDetailsP = getLegendInfo(obj.children{ind});
                end
                
                s = size(legendDetailsA,2) + size(legendDetailsB,2) + size(legendDetailsP,2);
                
                legendDetails(1,s) = nb_legendDetails();
                
                % Reorder the legend details
                if ~isempty(legendDetailsA)
                    legendDetails(obj.indexArea) = legendDetailsA;
                end
                
                if ~isempty(legendDetailsB)
                    legendDetails(logical(obj.indexGrouped + obj.indexStacked)) = legendDetailsB;
                end
                
                if ~isempty(legendDetailsP)
                    legendDetails(obj.indexLine) = legendDetailsP;
                end
               
            else
                
                legendDetails = [];
                
            end
            
        end
        
    end
    
    methods(Hidden=true)
        
        function [x,y,value] = notifyMouseOverObject(obj,cPoint)
        % cPoint : current point in data units
            
            x     = [];
            y     = [];
            value = [];
            for ii = length(obj.children):-1:1
                [x,yt,value] = notifyMouseOverObject(obj.children{ii},cPoint);
                if ~isempty(value)
                    switch class(obj.children{ii})
                        case 'nb_area'
                            t = 'area';
                        case 'nb_bar'
                            t = obj.children{ii}.style;
                        case 'nb_plot'
                            t = 'line';
                    end
                    y = find(strcmpi(t,obj.types));
                    y = y(yt);
                    break
                end
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Do the plotting
        -------------------------------------------------------------------
        %}
        function plotTypes(obj)
            
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
            % Decide the parent (MATLAB axes to plot on)
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
            
            if size(obj.xData,1) ~= size(obj.yData,1)
                error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same number of rows.'])
            end
            
            if size(obj.xData,2) ~= 1
                error([mfilename ':: The ''xData'' property must be a vector, but is a matrix with size; ' int2str(size(obj.xData,1)) 'x' int2str(size(obj.xData,2))])
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
            
            if size(obj.types,1) > 1
                error([mfilename ':: The ''types'' property must have size of the first dimension of 1.'])
            end
            
            if size(obj.types,2) ~= size(obj.yData,2)
                
                extra = size(obj.yData,2) - size(obj.types,2);
                
                if extra > 0
                    
                    warning('nb_plotComb:ToFewTypes',[mfilename ':: You have provided to few types. The unspecified types will be plotted as lines.'])
                    
                    extraTypes = cell(1,extra);
                    for ii = 1:extra
                        extraTypes{ii} = 'line';
                    end

                    obj.types = [obj.types extraTypes];
                    
                else
                    
                    warning('nb_plotComb:ToManyTypes',[mfilename ':: You have provided to many types. The leftovers are being deleted.'])
                    
                    obj.types = obj.types(1:size(obj.types,2));
                    
                end
                 
            end
            
            %--------------------------------------------------------------
            % Start the plotting
            %--------------------------------------------------------------
            
            %-----------------------Area----------------------------------- 
            obj.indexArea = strcmpi('area',obj.types);
            if sum(obj.indexArea) ~= 0%
                
                if ~isscalar(obj.baseValue)
                    error([mfilename ':: Cannot use set the ''baseValue'' input to a non scalar if some of the variables are plottes as ''area''.'])
                end
                
                areaColors = obj.cData(obj.indexArea,:);
                areaYData  = obj.yData(:,obj.indexArea);
                
                areaHandle = nb_area(obj.xData,areaYData,...
                    'abrupt'       , obj.abrupt,...
                    'baseValue'    , obj.baseValue,...
                    'cData'        , areaColors,...
                    'deleteOption' , obj.deleteOption,...
                    'lineStyle'    , obj.edgeLineStyle,...
                    'lineWidth'    , obj.edgeLineWidth,...
                    'parent'       , axh,...
                    'side'         , obj.side,...
                    'visible'      , obj.visible);
                
                % I need to make the baseline from this object invisible
                areaHandle.baseline.set('visible','off');
                
                obj.children = [obj.children , {areaHandle}];
                
            end
            
            %--------------------------Bar---------------------------------
            obj.indexStacked = strcmpi('stacked',obj.types);
            obj.indexGrouped = strcmpi('grouped',obj.types);
               
            if sum(obj.indexStacked) ~= 0 && sum(obj.indexGrouped) ~= 0
                
                error([mfilename ':: It is not possible to plot variables of type ''stacked'' and ''grouped'' at the same time'])
                 
            elseif sum(obj.indexStacked) ~= 0 || sum(obj.indexGrouped) ~= 0
                
                if sum(obj.indexStacked) ~= 0
                    
                    style    = 'stacked';
                    barColors = obj.cData(obj.indexStacked,:);
                    barYData  = obj.yData(:,obj.indexStacked);
                    
                else
                    
                    style     = 'grouped';
                    barColors = obj.cData(obj.indexGrouped,:);
                    barYData  = obj.yData(:,obj.indexGrouped);
                    
                end
                
                barHandle = nb_bar(obj.xData,barYData,...
                                   'alpha1'       , obj.alpha1,...  
                                   'alpha2'       , obj.alpha2,...  
                                   'baseValue'    , obj.baseValue,...
                                   'barWidth'     , obj.barWidth,...
                                   'blend'        , obj.blend,... 
                                   'cData'        , barColors,...
                                   'deleteOption' , obj.deleteOption,...
                                   'direction'    , obj.direction,...
                                   'edgeColor'    , obj.edgeColor,...
                                   'lineStyle'    , obj.edgeLineStyle,...
                                   'lineWidth'    , obj.edgeLineWidth,...
                                   'parent'       , axh,...
                                   'shadeColor'   , obj.shadeColor,...
                                   'shaded'       , obj.shaded,...
                                   'side'         , obj.side,...
                                   'style'        , style,...
                                   'visible'      , obj.visible);
                               
                 % I need to make the baseline from this object invisible
                 barHandle.baseline.set('visible','off');              
      
                 obj.children = [obj.children , {barHandle}];              
                               
            end
            
            %----------------------Lines-----------------------------------
            obj.indexLine = strcmpi('line',obj.types);
            
            if sum(obj.indexLine) ~= 0
                
                lineColors = obj.cData(obj.indexLine,:);
                lineYData  = obj.yData(:,obj.indexLine);
                
                lineHandle = nb_plot(obj.xData,lineYData,...
                    'cData'           , lineColors,...
                    'clipping'        , obj.clipping,...
                    'deleteOption'    , obj.deleteOption,...
                    'lineStyle'       , obj.lineStyle,...
                    'lineWidth'       , obj.lineWidth,...
                    'marker'          , obj.marker,...
                    'markerEdgeColor' , obj.markerEdgeColor,...
                    'markerFaceColor' , obj.markerFaceColor,...
                    'markerSize'      , obj.markerSize,...
                    'parent'          , axh,...
                    'side'            , obj.side,...
                    'visible'         , obj.visible);

                obj.children = [obj.children , {lineHandle}];
                
            end
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                
                % Update the axes given the plotted data
                obj.parent.addChild(obj);
                
            end
            
            %--------------------------------------------------------------
            % If the baseline property is empty we must initialize it
            %--------------------------------------------------------------
            if isscalar(obj.baseValue)
                
                if isa(obj.baseline,'nb_line')
                    if isvalid(obj.baseline)
                        obj.baseline.deleteOption = 'all';
                        delete(obj.baseline);
                    end
                    obj.baseline = [];
                end
                if isempty(obj.baseline)
                    obj.baseline = nb_horizontalLine(obj.baseValue,'parent',obj.parent,'visible',obj.visible,'side',obj.side);
                else
                    set(obj.baseline,'parent',obj.parent,'side',obj.side,'visible',obj.visible,'yData',obj.baseValue);
                end
                
            else
                
                if isa(obj.baseline,'nb_horizontalLine')
                    if isvalid(obj.baseline)
                        obj.baseline.deleteOption = 'all';
                        delete(obj.baseline);
                    end
                    obj.baseline = [];
                end
                if isempty(obj.baseline)
                    obj.baseline = nb_line(obj.xData,obj.baseValue,'parent',obj.parent,'visible',obj.visible,'side',obj.side,'lineWidth',obj.lineWidth(1));
                else
                    set(obj.baseline,'xData',obj.xData,'yData',obj.baseValue,'parent',obj.parent,'visible',obj.visible,'side',obj.side,'lineWidth',obj.lineWidth(1));
                end
                
            end
            
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
    
end
 
    
