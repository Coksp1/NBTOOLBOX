classdef nb_area < nb_plotHandle & nb_notifiesMouseOverObject
% Syntax:
%     
% obj = nb_area(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for making area plots.
% 
% The handle have set and get methods as all MATLAB graph handles. 
%     
% Caution: All the children of this object is of class nb_patch (or line)     
%     
% Constructor:
%     
%     obj = nb_area(xData,'propertyName',propertyValue,...)
%     obj = nb_area(xData,yData,'propertyName',propertyValue,...)
%     
%     Input:
%     
%     - xData    : The xData of the plotted data. Must be of size;
%                  size(yData,1) x 1 or 1 x size(yData,1)
%                          
%     - yData    : The yData of the plot. The columns are counted 
%                  as seperate variables
%         
%     - varargin : ...,'propertyName',propertyValue,...      
%     
%     Output:
%     
%     - obj      : An object of class nb_area
%     
%     Examples:
%     
%     obj = nb_area([1,2]); % Provide only y-axis data
%     obj = nb_area([1,2],[1,2]);
%     obj = nb_area([1,2],'propertyName',propertyValue,...)
%     obj = nb_area([1,2],[1,2],'propertyName',propertyValue,...)
% 
% See also: 
% area      
%     
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties (SetAccess=protected)
        
        % All the handles of the area plot, as patch objects
        children            = []; 
        
    end
    
    properties
       
        % Set this property to true to make the areas abruptly 
        % finish when given as nan.
        abrupt              = false;
        
        % Set if the areas should be accumulated or not. Default is true.
        accumulate          = true;
        
        % An nb_horizontalLine handle (object). Use the 
        % set and get methods of this handle to change 
        % the baseline properties 
        baseline            = [];
        
        % The base value of the area and bar plot. Must be a scalar.
        % Default is 0.
        baseValue           = 0;         
        
        % The color data of the line plotted. Must be 
        % of size; size(yData,2) x 3 with the RGB 
        % colors or a cellstr with size 1 x 
        % size(yData,2) with the color names.
        cData               = []; 
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption        = 'only';
        
        % Transparency of the patch face. Only the scalar option is 
        % supported. A single non-NaN value between 0 and 1 that 
        % controls the transparency of all the faces of the object. 
        % 1 (the default) means fully opaque and 0 means completely 
        % transparent (invisible)
        faceAlpha           = 1; 
          
        % {'off'} : Not included in the legend. 'on' : 
        % included in the legend
        legendInfo          = 'on';
        
        % The line style of the edge of the areas. Either a 
        % string or a cell array with size as the 
        % number of lines to be plotted. {'-'} | '--' |
        % ':' | '-.' | 'none'. 
        lineStyle           = '-'; 
        
        % The line width of the edge of the area. As a scalar. 
        % Default is 1
        lineWidth           = 1;         
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes (Which is the default).
        side                = 'left';   
        
        % If given the sum of the bars for each 
        % period will sum up to this number (only 
        % when style i set to 'syacked'). E.g. if
        % set 100, each bar for each variable will 
        % be given as percentage share of the total 
        % sum. 
        sumTo               = [];        
        
        % Sets the visibility of the plotted lines. {'on'} | 'off' 
        visible             = 'on'; 
        
        % The xData of the plotted data. Must be of
        % size; size(yData,1) x 1 or 1 x 
        % size(yData,1)
        xData               = [];        
        
        % The yData of the plot. The columns are 
        % counted as seperate variables
        yData               = [];       
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        type = 'patch';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        %{
        -------------------------------------------------------------------
        Constructor of the nb_area class
        -------------------------------------------------------------------
        %}
        function obj = nb_area(xData,yData,varargin)
            
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
                plotArea(obj);
            end
            
        end
        
        function set.abrupt(obj,value)
            if ~islogical(value)
                error([mfilename ':: The abrupt property must be'...
                                 ' set to a logical.'])
            end
            obj.abrupt = value;
        end
        
        function set.accumulate(obj,value)
            if ~islogical(value)
                error([mfilename ':: The accumulate property must be'...
                                 ' set to a logical.'])
            end
            obj.accumulate = value;
        end
        
        function set.baseline(obj,value)
            if ~isa(value,'nb_horizontalLine')  && ~isempty(value)
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
        
        function set.faceAlpha(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The faceAlpha property must be'...
                                 ' set to a scalar number in the set [0,1].'])
            elseif value < 0 || value > 1
                error([mfilename ':: The faceAlpha property must be'...
                                 ' set to a scalar number in the set [0,1].'])
            end
            obj.faceAlpha = value;
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
                                 ' set to a scalar.'])
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
        
        function set.sumTo(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The sumTo property must be'...
                                 ' set to a double.'])
            end
            obj.sumTo = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The visible property must be'...
                                 ' set to either ''on'' or ''off''.'])
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
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be '...
                                 'given as a double'])
            end
            obj.yData = value;
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

            % Delete the baseline
            if isa(obj.baseline,'nb_horizontalLine')
                obj.baseline.deleteOption = obj.deleteOption;
                obj.baseline.delete();
            end
            
            % Delete all the children of the object 
            if obj.deleteOption
                for ii = 1:size(obj.children,2)
                    if ishandle(obj.children(ii))
                        % Then delete
                        delete(obj.children(ii));
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
        
            xlimit    = [min(obj.xData),max(obj.xData)];
            xlimit(1) = xlimit(1);
            xlimit(2) = xlimit(2);
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
           
            if ~isempty(obj.sumTo)

                data       = obj.yData;
                tot        = sum(data,2);
                tot        = repmat(tot,[1,size(data,2),1]);
                data       = data./tot;
                data       = data*obj.sumTo;
                upos       = zeros(size(data));
                uneg       = upos;
                ipos       = data >= obj.baseValue;
                ineg       = data < obj.baseValue;
                upos(ipos) = data(ipos);
                uneg(ineg) = data(ineg);
                dataLow    = sum(uneg,2);
                dataHigh   = sum(upos,2);
                dataLow    = dataLow*0.99;
                dataHigh   = dataHigh*0.99;

            else

                data       = obj.yData;
                upos       = zeros(size(data));
                uneg       = upos;
                ipos       = data >= obj.baseValue;
                ineg       = data < obj.baseValue;
                upos(ipos) = data(ipos);
                uneg(ineg) = data(ineg);
                dataLow    = sum(uneg,2);
                dataHigh   = sum(upos,2);

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
            obj.baseline.setVisible();
            for ii = 1:size(obj.children,2)
                if ishandle(obj.children(ii))
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
            
            legendDetails(1,size(obj.yData,2)) = nb_legendDetails();
            if strcmpi(obj.legendInfo,'on')
            
                % Loop through the children (nb_patch objects)
                for ii = 1:size(obj.yData,2)

                    legendDetails(1,ii).patchColor             = obj.cData(ii,:);
                    legendDetails(1,ii).patchEdgeColor         = 'same';
                    legendDetails(1,ii).patchEdgeLineStyle     = obj.lineStyle;
                    legendDetails(1,ii).patchEdgeLineWidth     = obj.lineWidth;
                    legendDetails(1,ii).type                   = 'patch';

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
            
            % Seperate positive and negative 
            yDataPos             = obj.yData;
            yDataNeg             = obj.yData;
            indDataNeg           = yDataPos<0;
            yDataPos(indDataNeg) = 0;
            yDataNeg(yDataNeg>0) = 0;
            
            % Work in normal units
            normalLimits            = [0 1];
            baseV                   = nb_pos2pos(obj.baseValue, get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));
            baseV                   = baseV(ones(size(obj.yData)));
            xPointer                = nb_pos2pos(cPoint(1), get(ax, 'xLim'), normalLimits, get(ax, 'xScale'));
            yPointer                = nb_pos2pos(cPoint(2), get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));
            xDataNormal             = nb_pos2pos(obj.xData, get(ax, 'xLim'), normalLimits, get(ax, 'xScale'));
            yDataPosNormal          = nb_pos2pos(yDataPos, get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));
            yDataPosNormal          = cumsum(yDataPosNormal - baseV, 2) + baseV;
            yDataNegNormal          = nb_pos2pos(yDataNeg, get(ax, 'yLim'), normalLimits, get(ax, 'yScale'));
            yDataNegNormal          = cumsum(yDataNegNormal - baseV, 2) + baseV;
            yDataNormal             = yDataPosNormal;
            yDataNormal(indDataNeg) = yDataNegNormal(indDataNeg);
            
            % Find closest data point
            distances = bsxfun(@plus, ...
                (xDataNormal - xPointer) .^ 2, ...
                (yDataNormal - yPointer) .^ 2);
            [closestDistance, ind] = min(distances(:));
            closestDistance = sqrt(closestDistance);
            [x, y] = ind2sub(size(distances), ind);
            
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
        The method which does the plotting
        -------------------------------------------------------------------
        %}
        function plotArea(obj)
            
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
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,1) == 1
                obj.xData = obj.xData';
            end
            
            if size(obj.yData,1) ~= size(obj.xData,1)
                obj.yData = obj.yData';
            end
            
            if size(obj.xData,2) ~= 1
                error([mfilename ':: The ''xData'' property must either be a row or a column vector.'])
            end
            
            if size(obj.xData,1) ~= size(obj.yData,1)
                error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same number of rows.'])
            end
            
            if isempty(obj.cData)
                
                obj.cData = nb_plotHandle.getDefaultColors(size(obj.yData,2));
                
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,2) ~= 3
                    error([mfilename ':: The ''cData'' property must be a Mx3 matrix with the rgb colors of the plotted data.'])
                elseif size(obj.cData,1) ~= size(obj.yData,2)
                    error([mfilename ':: The ''cData'' property has not as many rows (' int2str(size(obj.cData,1)) ') as the property ''yData'' has columns (' int2str(size(obj.yData,2)) ').'])
                end
                
            elseif iscell(obj.cData)
                
                if length(obj.cData) ~= size(obj.yData,2)
                    error([mfilename ':: The cellstr arry given by ''cData'' property has not the same length (' int2str(length(obj.cData)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
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
            % Split the data into the positiv and negativ data
            %--------------------------------------------------------------
            if ~isempty(obj.sumTo)
                
                % Here we see all the data realtive to the total for each
                % period
                data = obj.yData;
                tot  = sum(data,2);
                tot  = repmat(tot,[1,size(data,2),1]);
                data = data./tot;
                data = data*obj.sumTo;
                
            else              
                data = obj.yData;
            end
            
            if ~obj.accumulate
                
                childs = [];
                
                % All areas start from 0
                x = [obj.xData;flipud(obj.xData)];
                for jj = 0:size(data,2) - 1

                    colorTemp = obj.cData(end - jj,:);
                    if any(data(:,end - jj),1)

                        y1 = data(:,end - jj);
                        y2 = zeros(size(data,1),1);
                        y  = [y1 + y2; flipud(y2)];
                        p  = patch(x,y,colorTemp,...
                                     'faceAlpha',   obj.faceAlpha,...
                                     'parent',      par,...
                                     'lineStyle',   'none',...
                                     'visible',     obj.visible);
                        l  = line(obj.xData,y1,...
                            'color',    colorTemp,...
                            'lineWidth',obj.lineWidth,...
                            'lineStyle',obj.lineStyle,...
                            'parent',   par);
                        childs = [childs, p, l]; %#ok%

                    end

                end
                
                obj.children = childs;
            
            else
            
                y1Pos       = zeros(size(data));
                y1Neg       = y1Pos;
                ipos        = data >= obj.baseValue;
                ineg        = data < obj.baseValue;
                y1Pos(ipos) = data(ipos);
                y1Neg(ineg) = data(ineg);

                %--------------------------------------------------------------
                % Start plotting
                %--------------------------------------------------------------
                try

                    childs = [];

                    % The positive values
                    for jj = 0:size(y1Pos,2) - 1

                        colorTemp = obj.cData(end - jj,:);

                        if any(y1Pos(:,end - jj),1)

                            x  = [obj.xData;flipud(obj.xData)];
                            y1 = y1Pos(:,end - jj);
                            if jj == (size(y1Pos,2) - 1)
                                y2 = zeros(size(y1Pos,1),1);
                            else
                                y2 = sum(y1Pos(:,1:end - jj - 1),2);
                            end
                            y = [y1 + y2; flipud(y2)];
                            if obj.abrupt
                                isNaN = isnan(data(:,end-jj));
                                prev  = isNaN(1);
                                for ii = 2:length(isNaN)
                                    current = isNaN(ii);
                                    if current ~= prev
                                        if current
                                            x = [x(1:ii-1);x(ii-1);x(ii:end)];
                                            y = [y(1:ii-1);y2(ii-1);y(ii:end)];
                                        else
                                            x  = [x(1:end-ii+1);x(end-ii+2);x(end-ii+2:end)];
                                            try
                                                y2 = flipud(sum(y1Pos(:,1:end - jj - 2),2));
                                            catch
                                                y2 = zeros(size(y1Pos,1),1);
                                            end
                                            y  = [y(1:end-ii+1);y2(end-ii+2);y(end-ii+2:end)];
                                        end
                                    end
                                    prev = current;
                                end
                            end

                            p = patch(x,y,colorTemp,...
                                         'edgeColor',   colorTemp,...
                                         'faceAlpha',   obj.faceAlpha,...
                                         'parent',      par,...
                                         'lineWidth',   obj.lineWidth,...
                                         'lineStyle',   obj.lineStyle,...
                                         'visible',     obj.visible);
                            childs = [childs, p]; %#ok%

                        end

                    end

                    % The negative values
                    for jj = 0:size(y1Neg,2) - 1

                        colorTemp = obj.cData(end - jj,:);

                        if any(y1Neg(:,end - jj),1)

                            x  = [obj.xData;flipud(obj.xData)];
                            y1 = y1Neg(:,end - jj);
                            if jj == (size(y1Neg,2) - 1)
                                y2 = zeros(size(y1Neg,1),1);
                            else
                                y2 = sum(y1Neg(:,1:end - jj - 1),2);
                            end
                            y  = [y1 + y2; flipud(y2)];
                            if obj.abrupt
                                isNaN = isnan(data(:,end-jj));
                                prev  = isNaN(1);
                                for ii = 2:length(isNaN)
                                    current = isNaN(ii);
                                    if current ~= prev
                                        if current
                                            x = [x(1:ii-1);x(ii-1);x(ii:end)];
                                            y = [y(1:ii-1);y2(ii-1);y(ii:end)];
                                        else
                                            x  = [x(1:end-ii+1);x(end-ii+2);x(end-ii+2:end)];
                                            try
                                                y2 = flipud(sum(y1Neg(:,1:end - jj - 2),2));
                                            catch
                                                y2 = zeros(size(y1Neg,1),1);
                                            end
                                            y  = [y(1:end-ii+1);y2(end-ii+2);y(end-ii+2:end)];
                                        end
                                    end
                                    prev = current;
                                end
                            end

                            p = patch(x,y,colorTemp,...
                                         'edgeColor',   colorTemp,...
                                         'faceAlpha',   obj.faceAlpha,...
                                         'parent',      par,...
                                         'lineWidth',   obj.lineWidth,...
                                         'lineStyle',   obj.lineStyle,...
                                         'visible',     obj.visible);
                            childs = [childs, p]; %#ok

                        end

                    end
                    obj.children = childs;

                catch Err

                    if ~isempty(obj.children)
                        for ii = 1:length(obj.children)
                            if ishandle(obj.children(ii))
                                delete(obj.children(ii));
                            end
                        end
                        obj.children = [];
                    end

                    % Rethrow the error message
                    rethrow(Err);

                end

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
            if isempty(obj.baseline)
                obj.baseline = nb_horizontalLine(obj.baseValue,'parent',...
                         obj.parent,'visible',obj.visible,'side',obj.side);
            else
                set(obj.baseline,'parent',obj.parent,'side',obj.side,...
                              'visible',obj.visible,'yData',obj.baseValue);    
            end
            
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
    
end
