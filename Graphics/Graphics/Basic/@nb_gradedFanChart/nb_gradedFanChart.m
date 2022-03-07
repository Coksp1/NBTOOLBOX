classdef nb_gradedFanChart < nb_plotHandle
% Syntax:
%     
% obj = nb_gradedFanChart(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for plotting a graded fan chart.  
%     
% Caution: Use the nb_colormap or the nb_axes.colorMap property to set
%          colors of the fan. If the colormap specifies to few colors they
%          are used to construct an interpolated colormap.
%
% Constructor:
%     
%     nb_gradedFanChart(yData)
%     nb_gradedFanChart(xData,yData)  
%     nb_gradedFanChart(xData,yData,'propertyName',propertyValue,...)
%     handle = nb_gradedFanChart(xData,yData,'propertyName',...
%                                   propertyValue,...)
%     
%     Input:
% 
%     - xData    : The xData of the plotted data. Must be of size;
%                  size(yData,1) x 1 or 1 x size(yData,1)
%                        
%     - yData    : The yData of the plot. The columns are counted 
%                  as different simualations. And on the basis of this  
%                  data the confidence intervals are calculated.
%         
%     - varargin : ...,'propertyName',propertyValue,...
%     
%     Output
% 
%     - obj      : An object of class nb_gradedFanChart
%     
%     Examples:
%
%     obj = nb_gradedFanChart(rand(2,100)); % Provide only y-axis data
%     obj = nb_gradedFanChart([1,2],rand(2,100));
%     obj = nb_gradedFanChart(rand(2,100),'propertyName',propertyValue,...)
%     obj = nb_gradedFanChart([1,2],rand(2,100),'propertyName',...
%                        propertyValue,...)    
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties(SetAccess=protected)
        
        % The children of the plot, as MATLAB patch handles.
        children = [];                  
          
    end
    properties
       
        % Transparency of fan chart. A double between 0 and 1. 0 fully 
        % transparent, 1 opaque.
        alpha               = 1;
        
        % An nb_line object with the mean, if you set this as a 
        % string the mean will not be plotted
        central             = [];
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are 
        % removed from the figure it is plotted on. If on the 
        % other hand 'only' is given, it will just delete the 
        % object.
        deleteOption        = 'only'; 
        
        % {'off'} : The mean line will not be included in the 
        % legend. 'on' : included it in the legend
        legendInfo          = 'on';               
        
        % The line width of center of the fan. See also property center.
        lineWidth           = 2.5; 
        
        % If the the data is all in level use 'level', if one is in level
        % and the rest is in diff to the first column use 'diff'. When
        % set to 'level' the data is sorted and transformed to the format
        % needed when set to 'diff'.
        method              = 'level';
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default)
        side                = 'left';   
        
        % Either 'patch' and 'line'.
        style               = 'patch';
        
        % Set the visibility of the fan chart.
        visible             = 'on'; 
        
        % The x-axis data. Should be a nObs x 1 vector.
        xData               = [];               
        
        % Each column of the yData property is counted as one 
        % simualation. As a nObs x nSim.
        %
        % Caution : If this property is set to nObs x 2 double, it will
        %           take the data as the upper and lower limit of the
        %           graded fan, and the size of the color map (see 
        %           nb_axes.colorMap) will decide the number points
        %           used for the graded fan chart.
        yData               = [];               
        
    end
    
    properties (Hidden=true)
    
        % Property storing the actual color of each line in the plot. Used
        % by the color bar if added.
        cData 
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        highest             = [];
        lowest              = [];
        type                = 'patch';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function set.alpha(obj,value)
            if ~nb_isScalarNumber(value) && ~(value <= 1 && value >=0)
                error([mfilename ':: The alpha property must be'...
                    ' set to a double contained in [0,1].'])
            end
            obj.alpha = value;
        end

        function set.central(obj,value)
            if ~isa(value,'nb_line') && ~isempty(value)
                error([mfilename ':: The central property must be'...
                    ' given as an nb_line object or empty.'])
            end
            obj.central = value;
        end
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.legendInfo(obj,value)
            if ~~any(strcmp({'off','on'},value))
                error([mfilename '::  The legendInfo property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
        end
        
        function set.lineWidth(obj,value)
            if ~isscalar(value)
                error([mfilename ':: The lineWidth property must be'...
                    ' set to a scalar double.'])
            end
            obj.lineWidth = value;
        end
        
        function set.method(obj,value)
            if ~any(strcmp({'level','diff'},value))
                error([mfilename '::  The method property must be '...
                    'either ''level'' or ''diff'' (default).'])
            end
            obj.method = value;
        end
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename '::  The side property must be '...
                    'either ''right'' or ''left'' (default).'])
            end
            obj.side = value;
        end
        
        function set.visible(obj,value)
            if ~~any(strcmp({'on','off'},value))
                error([mfilename '::  The visible property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
        
        function set.xData(obj,value)
            if ~any(ismember(size(value),1)) && ~isa(value,'double') && ...
                    ~isempty(value)
                error([mfilename ':: The xData property must be'...
                    ' of size; size(yData,1) x 1 or'...
                    ' 1 x size(yData,1).'])
            end
            obj.xData = value;
        end
        
        function set.yData(obj,value)
            if ~isa(value,'double') && ~isempty(value)
                error([mfilename ':: The yData property must be'...
                    ' given as a double.'])
            end
            obj.yData = value;
        end
        
        
        function obj = nb_gradedFanChart(xData,yData,varargin)
            
            if nargin < 2
                
                if nargin == 1
                    obj.yData = xData;
                    obj.xData = 1:size(xData,1);
                else
                    obj.xData = [0;1];
                    obj.yData = rand(2,50);
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
                plotFan(obj);
            end
            
        end
        
        varargout = set(varargin)
        varargout = get(varargin)
        
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
            
            if strcmpi(obj.deleteOption,'all')
                
                % Delete all the children of the object
                for ii = 1:size(obj.children,2)
                    if ishandle(obj.children(ii))
                        % Then delete
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
            
            % Find the method to use
            if isa(obj.parent,'nb_axes')
                meth   = obj.parent.findAxisLimitMethod;
                if isa(obj.parent.parent,'nb_figure')
                    fig = obj.parent.parent.figureHandle;
                else
                    fig = obj.parent.parent;
                end
            else
                meth   = 4;
                fig    = get(obj.parent,'parent');
            end
            dataLow  = obj.lowest;
            dataHigh = obj.highest;
            ylimit   = nb_plotHandle.findLimitsAlgo(dataLow,dataHigh,meth,fig);
            
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
            obj.central.setVisible();
            
        end
        
        function legendDetails = getLegendInfo(obj)
            
            % Get the legend info from the central line
            legendDetails = obj.central.getLegendInfo();
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Plot the fan chart
        -------------------------------------------------------------------
        %}
        function plotFan(obj)
            
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
            
            if size(obj.xData,1) ~= size(obj.yData,1)
                error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same number of rows.'])
            end
            
            if size(obj.xData,2) ~= 1
                error([mfilename ':: The ''xData'' property can anly have one columns or one row.']) 
            end
            
            % Get the color data
            if isa(obj.parent,'nb_axes')
                colors = getColorMap(obj.parent);
            else
                colors = get(obj.parent,'colorMap');
            end
            if size(obj.yData,2) == 2
                
                nCol = size(colors,1);
                data = nan(size(obj.yData,1),nCol);
                for ii = 1:size(obj.yData,1)
                    data(ii,:) = linspace(obj.yData(ii,1),obj.yData(ii,2),nCol);
                end
                
            else
            
                data = obj.yData;
                if size(colors,1) < size(obj.yData,2)

                    if size(colors,1) > 10
                        index  = ceil(linspace(1,size(colors,1),10));
                        colors = colors(index,:);
                    end
                    nLines   = size(obj.yData,2);
                    nColors  = size(colors,1);
                    num      = ceil(nLines/(nColors - 1)); 
                    spectrum = nan(nLines,3);
                    start    = 1;
                    for ii = 1:nColors-2
                        spectrum(start:start+num-1,1) = linspace(colors(ii,1),colors(ii+1,1),num)';  
                        spectrum(start:start+num-1,2) = linspace(colors(ii,2),colors(ii+1,2),num)';
                        spectrum(start:start+num-1,3) = linspace(colors(ii,3),colors(ii+1,3),num)';
                        start                         = start + num;
                    end
                    spectrum(start:end,1) = linspace(colors(end-1,1),colors(end,1),nLines - start + 1)';  
                    spectrum(start:end,2) = linspace(colors(end-1,2),colors(end,2),nLines - start + 1)';
                    spectrum(start:end,3) = linspace(colors(end-1,3),colors(end,3),nLines - start + 1)';
                    colors                = spectrum;

                end
                
            end
            obj.cData = colors;
            
            %--------------------------------------------------------------
            % Do the plotting
            %--------------------------------------------------------------
            if strcmpi(obj.method,'level')
                data = sort(data,2);
            else
                data = cumsum(data,2);
            end
            
            if isnan(obj.lineWidth)
                lineW = 3;
            else
                lineW = obj.lineWidth;
            end
            x  = obj.xData;
            hh = nb_gobjects(1,size(data,2));
            if strcmpi(obj.style,'line')
                for ii = 1:size(data,2)
                    hh(ii) = line(x,data(:,ii),'color',colors(ii,:),'parent',axh,'lineWidth',lineW,'clipping','on'); 
                end
            else
                for ii = size(data,2):-1:2
                    low    = data(:,ii-1);         
                    upp    = data(:,ii); 
                    hh(ii) = plotOne(obj,axh,x,low,upp,colors(ii-1,:)); 
                end 
            end
            
            % For limits of the axes
            obj.lowest  = data(:,1);
            obj.highest = data(:,end);
            
            %--------------------------------------------------------------
            % Assign the children
            %--------------------------------------------------------------
            obj.children = hh;
            
            %--------------------------------------------------------------
            % Get the mean
            %--------------------------------------------------------------
            meanData = mean(data,2);
            
            %--------------------------------------------------------------
            % Plot the mean data, if not set to 'none'
            %--------------------------------------------------------------
            if ~ischar(obj.central)
                obj.central = nb_line(obj.xData,meanData,...
                                  'lineWidth',obj.lineWidth,...
                                  'parent',axh,...
                                  'visible',obj.visible);
            end
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                % Update the axes given the plotted data
                obj.parent.addChild(obj);
            end
            
        end
        
        function hh = plotOne(obj,axh,x,low,upp,cData)
                
            good   = ~isnan(low) & ~isnan(upp);
            filled = [upp(good);flipud(low(good))];
            xTemp  = x(good);
            xTemp  = [xTemp(:);flipud(xTemp(:))];

            hh = patch(xTemp,filled,cData,...
                           'clipping',  'on',...
                           'edgeColor', cData,...
                           'faceAlpha', obj.alpha,...
                           'edgeAlpha', 0,...
                           'lineStyle', 'none',...
                           'parent',    axh,...
                           'visible',   obj.visible);

            % Remove it form the legend object
            set(get(get(hh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

        end
            
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true,Hidden=true)
        
    end
    
end
