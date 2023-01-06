classdef nb_plotBarAtEnd < nb_plot
% Syntax:
%     
% obj = nb_plotBarAtEnd(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle, nb_plot
%     
% Description:
%     
% This is A class for plotting data by lines (2D), but then switch to bar 
% plot at the end.
%     
% Constructor:
%     
%     nb_plotBarAtEnd(yData)
%     nb_plotBarAtEnd(xData,yData)  
%     nb_plotBarAtEnd(xData,yData,'propertyName',propertyValue,...)
%     h = nb_plotBarAtEnd(xData,yData,'propertyName',propertyValue,...)  
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
%     - obj : An object of class nb_plotBarAtEnd
%     
%     Examples:    
% 
%     h = nb_plotBarAtEnd(1:150,rand(150,1),'lineStop',40,'barPeriods',[50,100,150]);      
%     
% See also:
% plot, nb_plot, nb_bar, bar
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The periods for where to plot the bar. E.g 3 or [3,4]
        barPeriods  = [];
        
        % A string with the color specification to use for the bars 
        % ({'nb'} | 'red' | 'green' | 'yellow' | '')
        cDataBar    = 'nb'; 
        
        % The width of the bars at the end.
        endBarWidth = 3;
        
        % The period that the line should be stopped. E.g. 2.
        lineStop    = [];
        
    end
    
    %======================================================================
    % The accessible methods of the class
    %======================================================================
    methods 
        
        function set.barPeriods(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The barPeriods property must be '...
                      'given as a double.'])
            end
            obj.barPeriods = value;            
        end
        
        function set.cDataBar(obj,value)
             if ~any(strcmp({'nb','red','green','yellow',''},value))
                error([mfilename ':: The cDataBar property must be'...
                                 ' set to either ''nb'', ''red'','...
                                 ' ''green'', ''yellow'' or as an'...
                                 ' empty one character array.'])
             end
            obj.cDataBar = value;            
        end
        
        function set.endBarWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The barPeriods property must be '...
                      'given as a scalar double.'])
            end
            obj.endBarWidth = value;            
        end
        
        function set.lineStop(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The lineStop property must be '...
                      'given as a scalar double.'])
            end
            obj.lineStop = value;            
        end
        
        function obj = nb_plotBarAtEnd(xData,yData,varargin)
            
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
        
            if isempty(obj.lineStop) || obj.lineStop > obj.xData(end)
                data = obj.xData;
            else
                data   = obj.xData(1:obj.lineStop,:);
                barPer = obj.barPeriods(obj.xData(end)>=obj.barPeriods);
                if ~isempty(barPer)
                    barD   = obj.lineStop+obj.endBarWidth+1:obj.endBarWidth:obj.lineStop+length(barPer)*obj.endBarWidth+1;
                    data   = [data;barD(ones(1,size(data,2)),:)'];
                end
            end
            xlimit      = [min(min(data)),max(max(data))];
            xlimit(end) = xlimit(end) + obj.endBarWidth/2;
            
        end
            
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
            
            if isempty(obj.lineStop) || obj.lineStop > obj.xData(end)
                data = obj.yData;
            else
                data   = obj.yData(1:obj.lineStop,:);
                barPer = obj.barPeriods(obj.xData(end)>=obj.barPeriods);
                if ~isempty(barPer)
                    data = [data;obj.yData(barPer,:)];
                end
            end
            dataLow  = data;
            dataHigh = data;
            
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
                setVisible(obj.children{ii});               
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
            
            legendDetails = [];
            if strcmpi(obj.legendInfo,'on')
            
                % Loop through the children (nb_line and nb_bar objects)
                for ii = 1:size(obj.children,2)
                   legendDetails = [legendDetails, getLegendInfo(obj.children{ii})]; 
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
            
            % Get the plotted data
            if isempty(obj.lineStop) || obj.lineStop > obj.xData(end)
                dataY = obj.yData;
            else
                dataY  = obj.yData(1:obj.lineStop,:);
                barPer = obj.barPeriods(obj.xData(end)>=obj.barPeriods);
                if ~isempty(barPer)
                    dataY  = [dataY;obj.yData(barPer,:)];
                end
            end
            
            if isempty(obj.lineStop) || obj.lineStop > obj.xData(end)
                dataX  = obj.xData;
                dataXN = dataX;
            else
                dataX  = obj.xData(1:obj.lineStop,:);
                dataXN = obj.xData(1:obj.lineStop,:);
                barPer = obj.barPeriods(obj.xData(end)>=obj.barPeriods);
                if ~isempty(barPer)
                    dataX  = [dataX;obj.xData(obj.barPeriods,:)];
                    barD   = obj.lineStop + obj.endBarWidth + 1:obj.endBarWidth:obj.lineStop + length(barPer)*obj.endBarWidth + 1;
                    dataXN = [dataXN;barD(ones(1,size(dataXN,2)),:)'];
                end
            end
            
            % Work in normal units
            normalLimits = [0 1];
            xPointer     = nb_pos2pos(cPoint(1), get(ax, 'xLim'), normalLimits, get(ax, 'xScale'));
            yPointer     = nb_pos2pos(cPoint(2), get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));
            xDataNormal  = nb_pos2pos(dataXN, get(ax, 'xLim'), normalLimits, get(ax, 'xScale'));
            yDataNormal  = nb_pos2pos(dataY, get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));

            % Find closest data point
            distances              = (xDataNormal - xPointer) .^ 2 + (yDataNormal - yPointer) .^ 2;
            [closestDistance, ind] = min(distances(:));
            closestDistance        = sqrt(closestDistance);
            [x, y]                 = ind2sub(size(distances), ind);

            threshold = 0.015; 
            if closestDistance < threshold
                value = [dataX(x),dataY(x, y)];
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
                    obj.children{ii}.deleteOption = 'all';
                    delete(obj.children{ii});
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
            if size(obj.xData,2) > 1
                error([mfilename ':: The ''xData'' property must be a vector, but is a matrix with size; ' int2str(size(obj.xData,1)) 'x' int2str(size(obj.xData,2))])
            end
            
            if size(obj.yData,1) == 1
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
                    xLim     = [min([xLim(1),xLimAxes(1)]), max([xLim(2),xLimAxes(2)])];
                    yLim     = [min([yLim(1),yLimAxes(1)]), max([yLim(2),yLimAxes(2)])];
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
    
            % Get the end of line
            lineIsStopped = false;
            if isempty(obj.lineStop)
                endOfLine = size(x,1);
            else
                if obj.lineStop > size(x,1) || obj.lineStop < 1
                    warning([mfilename ':: The ''lineStop'' property is outside the x-axis limits.'])
                    endOfLine = size(x,1);
                else
                    endOfLine     = obj.lineStop;
                    lineIsStopped = true;
                end
                
            end
            
            ch(1,size(y,2)) = nb_line();
            for ii = 1:size(y,2)

                ch(ii).xData           = x(1:endOfLine); %#ok<*AGROW>
                ch(ii).yData           = y(1:endOfLine,ii);
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
            obj.children = nb_obj2cell(ch);
            
            %--------------------------------------------------------------
            % Plot the bars
            %--------------------------------------------------------------
            barPer = obj.barPeriods(obj.xData(end)>=obj.barPeriods);
            if lineIsStopped && ~isempty(barPer)
                
                barDataX = obj.xData(barPer);
                barDataC = barDataX/barDataX(end);
                cDataB   = nb_getFanColors(obj.cDataBar,barDataC');
               
                % Plot the bars
                barDataXT = endOfLine+obj.endBarWidth+1:obj.endBarWidth:endOfLine+size(barDataX,1)*obj.endBarWidth+1;
                barDataY  = obj.yData(barPer,:);
                bars      = cell(1,length(barDataX));
                barWidth  = obj.endBarWidth/2;
                for ii = 1:length(barDataX)
                    
                    xTemp    = [barDataXT(ii) - barWidth; barDataXT(ii) + barWidth];
                    x        = [xTemp(1);xTemp(1);xTemp(2);xTemp(2)];
                    y        = [0; barDataY(ii); barDataY(ii); 0];
                    bars{ii} = nb_patch(x,y,cDataB(ii,:),...
                                 'parent',      axh,...
                                 'lineStyle',   'none',...
                                 'legendInfo',  'off',...
                                 'visible',     obj.visible,...
                                 'side',        obj.side);
                
                end
                obj.children = [obj.children,bars];                
                
            end
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')          
                % Update the axes given the plotted data
                obj.parent.addChild(obj); 
            end
            
            if lineIsStopped && ~isempty(barPer) && isa(obj.parent,'nb_axes')
                
                xTicks      = obj.parent.xTick;
                ind         = xTicks > obj.lineStop;
                xTicks(ind) = [];
                xTicks      = [xTicks,barDataXT];
                xTicks      = unique(xTicks);
                xTickLabels = xTicks;
                for ii = length(barDataXT):-1:1
                   ind              = barDataXT(ii) == xTickLabels;
                   xTickLabels(ind) = barDataX(ii);
                end
                xTickLabels = strtrim(cellstr(int2str(xTickLabels')));
                set(obj.parent,'xTick',xTicks,'xTickLabel',xTickLabels);
                
            end
            
        end
        
    end
    
end
