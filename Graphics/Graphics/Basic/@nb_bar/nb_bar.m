classdef nb_bar < nb_plotHandle & nb_notifiesMouseOverObject
% Syntax:
%     
% obj = nb_bar(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for making bar plots with or without shaded bars.
% 
% nb_bar(yData)
% nb_bar(xData,yData)  
% nb_bar(xData,yData,'propertyName',propertyValue,...)
% handle = nb_bar(xData,yData,'propertyName',propertyValue,...)
%   
% The handle have set and get methods as all MATLAB graph handles. 
%     
% Caution: All the children of this object is of class nb_patch  
%     
% Constructor:
%     
%     obj = nb_bar(xData,yData,varargin)
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
%     Output
% 
%     - obj      : An object of class nb_bar
%     
%     Examples:
% 
%     obj = nb_bar([1,2]); % Provide only y-axis data
%     obj = nb_bar([1,2],[1,2]);
%     obj = nb_bar([1,2],'propertyName',propertyValue,...)
%     obj = nb_bar([1,2],[1,2],'propertyName',propertyValue,...)
%     
% See also: 
% 
% bar      
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties(SetAccess=protected)

        % All the handles of the bar plot.
        children = [];            
        
    end

    properties
        
        % Sets the alpha blending parameter nr 1 when blend is set to
        % true.
        alpha1                = 0.5;
        
        % Sets the alpha blending parameter nr 1 when blend is set to
        % true.
        alpha2                = 0.5;
        
        % Width of the bars. Must be a scalar.
        barWidth              = 0.45;      
        
        % A nb_horizontalLine handle (object). Use the set and get 
        % methods of this handle to change the baseline properties.
        %
        % Caution: If baseValue is a vector this property is a nb_line
        %          object.
        baseline              = [];    
        
        % The base value of the plot. Must be a scalar or a vector with 
        % size size(yData,1) x 1.
        baseValue             = 0;         
        
        % When shaded is used, and this option is set to true, it will do
        % alpha blending with shadeColor instead of shading.
        blend                 = false;
        
        % Color of the plotted data. A matrix; 
        % size(yData,2) x 3 (RGB color). Or a cellstr
        % with the color names. (With size 1 x size(yData,2))
        cData                 = []; 
        
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
        
        % {'off'} : Not included in the legend. 'on' : included in 
        % the legend
        legendInfo            = 'on';  
        
        % Sets the line style(s) of the edge of the bars. 
        % Either a string or a cellstr (which must have 
        % the size 1 x size(yData,2)).
        lineStyle             = '-'; 
        
        % The line width of the edge of the bars. Must be a scalar.
        lineWidth             = 1;         
        
        % Sets the tightness of the bars plotted. (Stacked)
        scale                 = 0;         
        
        % The color (RGB) the shaded bar plots are 
        % interpolated with. Either a 1x3 double with the
        % RGB colors or a string with the color name.
        % Default is [1,1,1]
        shadeColor            = [1, 1, 1]; 
        
        % Index of which data should be shaded. A matrix with size; 
        % size(yData,1) x 1 or 1 x size(yData,1) or size(yData,1) x 
        % size(yData,2)
        shaded                = [];     
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is of class nb_axes. (Which is the default)
        side                  = 'left';    
        
        % 'stacked' | {'grouped'} | 'dec'. When 'dec' is given the 
        % bars will be stacked but there will also be plotted a 
        % line with the sum. (It is not possible to use the sumTo 
        % option at the same time)
        style                 = 'grouped';
        
        % If given the sum of the bars for each period will sum up 
        % to this number. (only when style i set to 'syacked') 
        % E.g. if set 100, each bar for each variable will be given 
        % as percentage share of the total sum. 
        sumTo                 = [];
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'.
        visible               = 'on';
        
        % The xData of the plotted data. Must be of size; 
        % size(yData,1) x 1 or 1 x size(yData,1)
        xData                 = [];      
        
        % The yData of the plot. The columns are counted as 
        % seperate variables.
        yData                 = [];        
          
    end
    
    properties (SetAccess=protected)
        
        % Is the fast or general algorithm beeing used.
        fast                   = true;
        
        % A nb_line handle representing the sum of the stacked bars 
        % when 'style' is set to 'dec'. As a line handle.
        lineObj                = []; 
        
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
        
        function set.alpha1(obj,value)
            if ~nb_isScalarNumber(value,0,1)
                error([mfilename ':: The alpha1 property must be'...
                                 ' set to a number between 0 and 1.'])
            end
            obj.alpha1 = value;
        end
        
        function set.alpha2(obj,value)
            if ~nb_isScalarNumber(value,0,1)
                error([mfilename ':: The alpha2 property must be'...
                                 ' set to a number between 0 and 1.'])
            end
            obj.alpha2 = value;
        end
        
        function set.barWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The barWidth property must be'...
                                 ' set to a number.'])
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
        
        function set.blend(obj,value)
            if ~nb_isScalarLogical(value)
                error([mfilename ':: The blend property must be'...
                                 ' set to a scalar logical.'])
            end
            obj.blend = value;
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
        
        function set.direction(obj,value)
            if ~any(ismember({'east','south','west','north'},value)) &&...
                                                 ~nb_isOneLineChar(value)
                error([mfilename ':: The direction property must be'...
                                 ' set to a one line character array.'])
            end
            obj.direction = value;
        end
        
        function set.edgeColor(obj,value)
            
            if isempty(value)
                value = 'same';
            elseif ~nb_isColorProp(value,true)
                error([mfilename ':: The edgecolor property must'...
                                 ' have dimension size'...
                                 ' size(plotData,2) x 3 with the RGB'...
                                 ' colors or a cellstr with size 1 x'...
                                 ' size(yData,2) with the color names.'])
            end
            obj.edgeColor = value;
            
        end               
        
        function set.legendInfo(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The legendInfo property must be'...
                                 ' set to a one line character array.'])
            end
            obj.legendInfo = value;
        end
        
        function set.lineStyle(obj,value)
            if ~nb_islineStyle(value,true)
                error([mfilename ':: The lineStyle property must be'...
                                 ' set to a valid lineStyle property.'])
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
        
        function set.scale(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The scale property must be'...
                                 ' given as a scalar.'])
            end
            obj.scale = value;
        end
        
        function set.shadeColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The shadeColor property must'...
                                 ' must have dimension size'...
                                 ' 1 x 3 with RGB colors'...
                                 ' or a string with the color names.'])
            end
            obj.shadeColor = value;
        end
        
        function set.shaded(obj,value)
            if ~isa(value,'double') && ~isa(value,'logical')
                error([mfilename ':: The shaded property must be given as '...
                    'a double.'])
            end
            obj.shaded = value;
        end
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename ':: The side property must be set to '...
                                'either ''right'' or ''left'' (default).'])
            end
            obj.side = value;
        end
                
        function set.style(obj,value)
            if ~any(strcmp({'stacked','grouped','dec'},value))
                error([mfilename ':: The style property must be set to '...
                                'either ''stacked'', ''dec'' or '...
                                '''grouped'' (default).'])
            end
            obj.style = value;
        end
        
        function set.sumTo(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The sumTo property must be'...
                                 ' given as a double.'])
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
            if ~any(ismember(size(value),1)) && isa(value,'double')
                error([mfilename ':: The xData property must be'...
                                 ' of size; size(yData,1) x 1 or'...
                                 ' 1 x size(yData,1).'])
            end
            obj.xData = value;
        end
        
        function set.yData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be'...
                                 ' given as a double.'])
            end
            obj.yData = value;
        end
        
        function obj = nb_bar(xData,yData,varargin)
            
            if nargin == 0
                return;
            end
            
            if nargin < 2
                
                if nargin == 1
                    obj.yData = xData;
                    obj.xData = 1:size(xData,1);
                else
                    obj.xData = [0; 1];
                    obj.yData = [0.5; 1];
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
                plotBars(obj);
            end
            
        end
             
        varargout = get(varargin)
        
        varargout = set(varargin)
        
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
            try %#ok<TRYNC>
                obj.baseline.deleteOption = obj.deleteOption;
                obj.baseline.delete();
            end
            
            % Delete all the children of the object 
            for ii = 1:size(obj.children,2)
                try %#ok<TRYNC>
                    if isvalid(obj.children(ii))
                        obj.children(ii).deleteOption = obj.deleteOption;
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
            
            if strcmpi(obj.style,'stacked') || strcmpi(obj.style,'dec')
                
                if ~isempty(obj.sumTo)             
                    data = obj.yData;
                    tot  = sum(data,2);
                    tot  = repmat(tot,[1,size(data,2),1]);
                    data = data./tot;
                    data = data*obj.sumTo;
                else
                    data = obj.yData;  
                end
                upos = zeros(size(data));
                uneg = upos;
                if isscalar(obj.baseValue)
                    baseV      = obj.baseValue;
                    ipos       = data >= baseV;
                    ineg       = data < baseV;
                    upos(ipos) = data(ipos) - baseV;
                    uneg(ineg) = data(ineg) - baseV;
                else
                    baseV = obj.baseValue(:,ones(1,size(data,2)));
                    ipos  = data >= baseV;
                    ineg  = data < baseV;
                    upos(ipos) = data(ipos) - baseV(ipos);
                    uneg(ineg) = data(ineg) - baseV(ineg);
                end
                dataLow  = sum(uneg,2) + obj.baseValue;
                dataHigh = sum(upos,2) + obj.baseValue;
                if ~isempty(obj.sumTo) 
                    dataLow  = dataLow*0.99;
                    dataHigh = dataHigh*0.99;
                end
 
            else
                dataLow  = obj.yData;
                dataHigh = obj.yData;
            end
            
            % Need to add the base value, so it is included in the plot
            if isscalar(obj.baseValue)
                baseValues = ones(size(obj.yData,1),1)*obj.baseValue;
            else
                baseValues = obj.baseValue;
            end
            dataLow    = [dataLow,  baseValues];
            dataHigh   = [dataHigh, baseValues];
            
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
                
                obj.children(ii).setVisible();
                
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
            
            if isnumeric(obj.edgeColor) && size(obj.edgeColor,1) > 1
                sY    = size(obj.yData,2);
                edgeC = cell(1,sY);
                for ii = 1:sY
                    edgeC{ii} = obj.edgeColor(ii,:);
                end
            elseif ischar(obj.edgeColor) || isnumeric(obj.edgeColor)
                sY    = size(obj.yData,2);
                edgeC = cell(1,sY);
                for ii = 1:sY
                    edgeC{ii} = obj.edgeColor;
                end
            else 
                edgeC = obj.edgeColor;
            end
            
            legendDetails(1,size(obj.yData,2)) = nb_legendDetails();
            if strcmpi(obj.legendInfo,'on')
            
                % Loop through the children (nb_patch objects)
                for ii = 1:size(obj.yData,2)

                    legendDetails(1,ii).patchColor             = obj.cData(ii,:);
                    legendDetails(1,ii).patchDirection         = obj.direction;
                    legendDetails(1,ii).patchEdgeColor         = edgeC{ii};
                    legendDetails(1,ii).patchEdgeLineStyle     = obj.lineStyle{ii};
                    legendDetails(1,ii).patchEdgeLineWidth     = obj.lineWidth;
                    legendDetails(1,ii).type                   = 'patch';

                end
                     
            end
            
        end
  
    end
    
    methods(Hidden=true)
        
        function [x,y,value] = notifyMouseOverObject(obj,cPoint)
        % cPoint : current point in data units
            
            notifyEmpty = false;
            
            % Find out which data cell the mouse is over
            xTemp1 = obj.xData - obj.barWidth/2;
            xTemp2 = obj.xData + obj.barWidth/2;
            ind1   = find(cPoint(1) >= xTemp1,1,'last');
            ind2   = find(cPoint(1) <= xTemp2,1,'first');
            if isempty(ind1) || isempty(ind2)
                notifyEmpty = true;
            else
                if ind1 == ind2
                    x = ind1;
                else
                    notifyEmpty = true;
                end
            end
            
            if ~notifyEmpty
                
                switch obj.style
                    
                    case {'stacked','dec'}
                        
                        if ~isempty(obj.sumTo) && ~strcmpi(obj.style,'dec')
                            % Here we see all the data realtive to the total for each
                            % period
                            data = obj.yData(x,:);
                            tot  = sum(data,2);
                            data = data/tot;
                            data = data*obj.sumTo;
                        else
                            data = obj.yData(x,:);
                        end
                        
                        if isscalar(obj.baseValue)
                            baseV = obj.baseValue;
                        else
                            baseV = obj.baseValue(x);
                        end
                        
                        if cPoint(2) >= baseV
                            
                            data         = data - baseV;
                            cPoint(2)    = cPoint(2)  - baseV;
                            data(data<0) = zeros;
                            data         = cumsum(data,2);
                            y            = find(cPoint(2) <= data,1,'first');
                            if isempty(y)
                                notifyEmpty = true;
                            end
                            value = [obj.xData(x),obj.yData(x,y)];
                            
                        else
                            
                            data          = data - baseV;
                            cPoint(2)     = cPoint(2)  - baseV;
                            data(data>=0) = zeros;
                            data          = -data;
                            data          = cumsum(data,2);
                            y             = find(-cPoint(2) <= data,1,'first');
                            if isempty(y)
                                notifyEmpty = true;
                            end
                            value = [obj.xData(x),obj.yData(x,y)];
                            
                        end
                        
                    case 'grouped'
                        
                        % Wich "variable" is the mouse over
                        ind   = obj.yData(x,:)~=0 & ~isnan(obj.yData(x,:));
                        mm    = size(obj.yData(x,ind),2);
                        n     = size(obj.yData,2);
                        m     = (n - mm)/2;
                        xLoc  = obj.xData(x) - obj.barWidth/2 + m*obj.barWidth/n;
                        if mm > 0
                            temp  = obj.barWidth/n;
                            temp  = temp(:,ones(1,mm));
                            temp  = cumsum(temp,2);
                            xLoc  = xLoc + temp;
                        end
                        y = find(cPoint(1) <= xLoc,1,'first');

                        if isempty(y)
                            notifyEmpty = true;
                        else
                            yInd  = find(ind);
                            if isempty(yInd)
                                notifyEmpty = true;
                            else
                            
                                y = yInd(y);
                                if isscalar(obj.baseValue)
                                    baseV = obj.baseValue;
                                else
                                    baseV = obj.baseValue(x);
                                end

                                % Is it outside the bar?
                                value = [obj.xData(x),obj.yData(x,y)];
                                if cPoint(2) >= baseV
                                    if cPoint(2) > value(2)
                                        notifyEmpty = true;
                                    end
                                else
                                    if cPoint(2) < value(2)
                                        notifyEmpty = true;
                                    end
                                end
                            end
                            
                        end
                        
                    otherwise
                        error([mfilename ':: Unsupported ''style'' ' obj.style])
                        
                end
                
            end
            
            if notifyEmpty
                value = [];
                x     = [];
                y     = [];
            end
            
        end
        
        function deleteChildren(obj)
            
            if ~isempty(obj.children)
                if isa(obj.children,'nb_patch')
                    for ii = 1:length(obj.children)
                        if isvalid(obj.children(ii))
                            obj.children(ii).deleteOption = 'all';
                            delete(obj.children(ii));
                        end
                    end
                else
                    if ishandle(obj.children)
                        delete(obj.children);
                    end
                end
                obj.children = [];
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        function plotBars(obj)
            
            obj.fast = false; % The fast plotter does not work!
%             if ~isscalar(obj.baseValue) || (~isempty(obj.shaded) && any(obj.shaded ~= 0))
%                 obj.fast = false;
%             end
%             if strcmpi(obj.style,'grouped') && obj.barWidth ~= 0.45
%                 obj.fast = false;
%             end
%             if ~ischar(obj.lineStyle)
%                 obj.fast = false;
%             end
            if obj.fast
                plotBarsFast(obj);
            else
                plotBarsGeneral(obj);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        The method which does the plotting
        -------------------------------------------------------------------
        %}
        function plotBarsGeneral(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            deleteChildren(obj);
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,1) == 1
                obj.xData = obj.xData';
            end
            
            if size(obj.yData,1) == 1 && size(obj.xData,1) ~= 1
                obj.yData = obj.yData';
            end
            
            if size(obj.xData,2) > 1
                error([mfilename ':: The ''xData'' property must be a vector, but is a matrix with size; ' int2str(size(obj.xData,1)) 'x' int2str(size(obj.xData,2))])
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
            
            if isempty(obj.shaded)
                obj.shaded = zeros(size(obj.xData));
            end
            
            if size(obj.shaded,1) == 1
                obj.shaded = repmat(obj.shaded',[1,size(obj.yData,2)]);
            elseif size(obj.shaded,2) == 1
                obj.shaded = repmat(obj.shaded,[1,size(obj.yData,2)]);
            end
            
            if size(obj.shaded,2) ~= size(obj.yData,2)
                error([mfilename ':: The ''shaded'' and the ''yData'' properties has not the same number of columns.'])
            elseif size(obj.shaded,2) ~= size(obj.yData,2)
                error([mfilename ':: The ''shaded'' and the ''yData'' properties has not the same number of rows.'])
            end
            
            if isnumeric(obj.edgeColor) && size(obj.edgeColor,1) > 1
                if size(obj.edgeColor,1) ~= size(obj.yData,2)
                    error([mfilename ':: The property ''edgeColor'' has not the proper size. Must be ' int2str(size(obj.yData,2)) ' x 3.']);
                end
                sY    = size(obj.yData,2);
                edgeC = cell(1,sY);
                for ii = 1:sY
                    edgeC{ii} = obj.edgeColor(ii,:);
                end
            elseif ischar(obj.edgeColor) || isnumeric(obj.edgeColor)
                sY    = size(obj.yData,2);
                edgeC = cell(1,sY);
                for ii = 1:sY
                    edgeC{ii} = obj.edgeColor;
                end
            else 
                if length(obj.edgeColor) ~= size(obj.yData,2)
                    error([mfilename ':: The property ''edgeColor'' has not the proper size. '....
                        'Is 1x' int2str(length(obj.edgeColor)) ' or ' int2str(length(obj.edgeColor)) 'x1, but must be 1x' int2str(size(obj.yData,2))])     
                else
                    edgeC = obj.edgeColor;
                end
            end
            
            if ischar(obj.shadeColor)
                obj.shadeColor = nb_plotHandle.interpretColor(obj.shadeColor);
            elseif ~isnumeric(obj.shadeColor)
                error([mfilename ':: The shadeColor property must be 1x3 double or a string.'])
            end
            
            if ischar(obj.lineStyle)
                
                sY    = size(obj.yData,2);
                lineS = cell(1,sY);
                for ii = 1:sY
                    lineS{ii} = obj.lineStyle;
                end
                obj.lineStyle = lineS;
                
            else
                
                if length(obj.lineStyle) ~= size(obj.yData,2)
                    error([mfilename ':: The property ''lineStyle'' has not the proper size. '....
                        'Is 1x' int2str(length(obj.edgeColor)) ' or ' int2str(length(obj.edgeColor)) 'x1, but must be 1x' int2str(size(obj.yData,2))])
                else
                    lineS = obj.lineStyle;
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
            
            %--------------------------------------------------------------
            % Split the data into the positiv and negativ data
            %--------------------------------------------------------------
            if ~isempty(obj.sumTo) && ~strcmpi(obj.style,'dec')
                
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
            
            y1Pos = zeros(size(data));
            y1Neg = y1Pos;
            if isscalar(obj.baseValue)
                ipos        = data > obj.baseValue;
                ineg        = data < obj.baseValue;
                baseV       = obj.baseValue(ones(1,size(data,1)),:);
                baseVM      = obj.baseValue;
                y1Pos(ipos) = data(ipos) - baseVM;
                y1Neg(ineg) = data(ineg) - baseVM;
            else
                baseVM      = obj.baseValue(:,ones(1,size(data,2)));
                ipos        = data > baseVM;
                ineg        = data < baseVM;
                baseV       = obj.baseValue;
                y1Pos(ipos) = data(ipos) - baseVM(ipos);
                y1Neg(ineg) = data(ineg) - baseVM(ineg);
            end
            
            % Must set the spacing between the bars plotted
            scaleFactor = (max(max(obj.yData,[],1),[],2) - min(min(obj.yData,[],1),[],2))*obj.scale;
            
            %--------------------------------------------------------------
            % Start plotting
            %--------------------------------------------------------------
            try
            
                switch obj.style

                    case {'stacked','dec'}
                        if any(obj.shaded(:))
                            plotStacked(obj,y1Pos,y1Neg,lineS,edgeC,scaleFactor,baseV,par);
                        else
                            plotStackedFast(obj,y1Pos,y1Neg,scaleFactor,baseV,par);
                        end
                    case 'grouped'

                        % Find x-pos
                        n     = size(data,2);
                        xTemp = cell(size(data));
                        for ii = 1:size(data)
                            ind   = data(ii,:)~=0 & ~isnan(data(ii,:));
                            tData = data(ii,ind);
                            m     = size(tData,2);
                            m     = (size(y1Pos,2) - m)/2;
                            xt    = [obj.xData(ii) - obj.barWidth/2 + m*obj.barWidth/n;...
                                     obj.xData(ii) - obj.barWidth/2 + (1+m)*obj.barWidth/n];
                            for jj = find(ind)
                                xTemp{ii,jj} = xt;
                                xt           = xt + obj.barWidth/n;
                            end
                        end
                        
                        % The positiv values
                        for ii = 1:size(y1Pos,1)

                            for jj = 1:size(y1Pos,2)

                                if y1Pos(ii,jj) > 0

                                    colorTemp = obj.cData(jj,:);

                                    xt = xTemp{ii,jj};
                                    x  = [xt(1);xt(1);xt(2);xt(2)];
                                    y  = [0; y1Pos(ii,jj); y1Pos(ii,jj); 0];

                                    if obj.shaded(ii,jj)
                                        if obj.blend
                                            colorTemp = nb_alpha(colorTemp,obj.shadeColor,obj.alpha1,obj.alpha2);
                                        else
                                            colorTemp = [colorTemp; obj.shadeColor]; %#ok
                                        end
                                    end
                                    
                                    p = nb_patch(x,y + baseV(ii),colorTemp,...
                                                 'parent',      par,...
                                                 'lineWidth',   obj.lineWidth,...
                                                 'lineStyle',   lineS{jj},...
                                                 'direction',   obj.direction,...
                                                 'edgeColor',   edgeC{jj},...
                                                 'legendInfo',  'off',...
                                                 'visible',     obj.visible,...
                                                 'side',        obj.side);
                                             
                                    obj.children = [obj.children, p];

                                end
                                
                            end

                        end

                        % The negativ values
                        for ii = 1:size(y1Neg,1)

                            for jj = 1:size(y1Neg,2)

                                if y1Neg(ii,jj) < 0

                                    colorTemp = obj.cData(jj,:);

                                    xt = xTemp{ii,jj};
                                    x  = [xt(1);xt(1);xt(2);xt(2)];
                                    y  = [0; y1Neg(ii,jj); y1Neg(ii,jj); 0];

                                    if obj.shaded(ii,jj)
                                        if obj.blend
                                            colorTemp = nb_alpha(colorTemp,obj.shadeColor,obj.alpha1,obj.alpha2);
                                        else
                                            colorTemp = [colorTemp; obj.shadeColor]; %#ok
                                        end
                                    end
                                    
                                    p = nb_patch(x,y + baseV(ii),colorTemp,...
                                                 'parent',      par,...
                                                 'lineWidth',   obj.lineWidth,...
                                                 'lineStyle',   lineS{jj},...
                                                 'direction',   obj.direction,...
                                                 'edgeColor',   edgeC{jj},...
                                                 'legendInfo',  'off',...
                                                 'visible',     obj.visible,...
                                                 'side',        obj.side);
                                             
                                    obj.children = [obj.children, p];
                                    
                                end
                                
                            end

                        end

                    otherwise

                        error([mfilename ':: Unsupported style ' obj.style]);

                end
                
                % Add the line representing the sum of the stacked bars
                %----------------------------------------------------------
                if strcmpi(obj.style,'dec')
                    
                    if isempty(obj.lineObj)
                        baseM       = baseV(:,ones(1,size(data,2)));
                        tot         = sum(data - baseM,2) + baseV;
                        obj.lineObj = nb_line(obj.xData,tot,...
                                           'parent',obj.parent,...
                                           'lineWidth',obj.lineWidth);
                    else
                        set(obj.lineObj,'parent',obj.parent,'lineWidth',obj.lineWidth);
                    end
                    
                else
                    
                    if ~isempty(obj.lineObj)
                        obj.lineObj.deleteOption = 'all';
                        delete(obj.lineObj);
                        obj.lineObj = [];
                    end
                     
                end
                
            catch Err
                
                if ~isempty(obj.children)
                    for ii = 1:length(obj.children)
                        obj.children(ii).deleteOption = 'all';
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
                    obj.baseline = nb_line(obj.xData,obj.baseValue,'parent',obj.parent,'visible',obj.visible,'side',obj.side,'lineWidth',obj.lineWidth);
                else
                    set(obj.baseline,'xData',obj.xData,'yData',obj.baseValue,'parent',obj.parent,'visible',obj.visible,'side',obj.side,'lineWidth',obj.lineWidth);
                end
                
            end
              
        end
        
        %==================================================================
        function plotStackedFast(obj,y1Pos,y1Neg,scaleFactor,baseV,par)
            
            % The positiv coordinates
            xAllPos = cell(size(y1Pos));
            yAllPos = cell(size(y1Pos));
            for ii = 1:size(y1Pos,1)
                for jj = 0:size(y1Pos,2) - 1
                    if y1Pos(ii,end - jj) > 0
                        xTemp              = [obj.xData(ii) - obj.barWidth/2; obj.xData(ii) + obj.barWidth/2];
                        x                  = [xTemp(1);xTemp(1);xTemp(2);xTemp(2)];
                        y                  = [scaleFactor; y1Pos(ii,end - jj); y1Pos(ii,end - jj); scaleFactor];
                        y                  = y + sum(y1Pos(ii,1:end - jj - 1))  + baseV(ii);
                        xAllPos{ii,end-jj} = x;
                        yAllPos{ii,end-jj} = y;
                    end
                end
            end
            
            % The negativ coordinates
            xAllNeg = cell(size(y1Neg));
            yAllNeg = cell(size(y1Neg));
            for ii = 1:size(y1Neg,1)
                for jj = 0:size(y1Neg,2) - 1
                    if y1Neg(ii,end - jj) < 0
                        xTemp              = [obj.xData(ii) - obj.barWidth/2; obj.xData(ii) + obj.barWidth/2];
                        x                  = [xTemp(1);xTemp(1);xTemp(2);xTemp(2)];
                        y                  = [scaleFactor; y1Neg(ii,end - jj); y1Neg(ii,end - jj); scaleFactor];
                        y                  = y + sum(y1Neg(ii,1:end - jj - 1)) + baseV(ii);
                        xAllNeg{ii,end-jj} = x;
                        yAllNeg{ii,end-jj} = y;
                    end
                end
            end
            
            % Plot the bars with one patch object
            xAll   = [xAllPos;xAllNeg];
            yAll   = [yAllPos;yAllNeg];
            inpAll = cell(1,size(xAll,2));
            for ii = 1:size(xAll,2)
                
                x            = xAll(:,ii);
                y            = yAll(:,ii);
                i            = ~cellfun(@isempty,x);
                x            = x(i);
                y            = y(i);
                inp          = cell(1,3*size(x,1));
                inp(1:3:end) = x;
                inp(2:3:end) = y;
                inp(3:3:end) = {obj.cData(ii,:)};
                inpAll{ii}   = inp;
                
            end
            inpAll       = [inpAll{:}];
            obj.children = fill(inpAll{:},...
                'lineStyle','none',...
                'parent',   par,...
                'visible',  obj.visible);
                    
        end
        
        %==================================================================
        function plotStacked(obj,y1Pos,y1Neg,lineS,edgeC,scaleFactor,baseV,par)
            
            % The positiv values
            for ii = 1:size(y1Pos,1)

                for jj = 0:size(y1Pos,2) - 1

                    colorTemp = obj.cData(end - jj,:);

                    if y1Pos(ii,end - jj) > 0

                        xTemp = [obj.xData(ii) - obj.barWidth/2; obj.xData(ii) + obj.barWidth/2];
                        x     = [xTemp(1);xTemp(1);xTemp(2);xTemp(2)];
                        y     = [scaleFactor; y1Pos(ii,end - jj); y1Pos(ii,end - jj); scaleFactor];
                        y     = y + sum(y1Pos(ii,1:end - jj - 1));

                        if obj.shaded(ii,end - jj)
                            if obj.blend
                                colorTemp = nb_alpha(colorTemp,obj.shadeColor,obj.alpha1,obj.alpha2);
                            else
                                colorTemp = [colorTemp; obj.shadeColor]; %#ok
                            end
                        end

                        p = nb_patch(x,y + baseV(ii),colorTemp,...
                                     'parent',      par,...
                                     'lineWidth',   obj.lineWidth,...
                                     'lineStyle',   lineS{end - jj},...
                                     'direction',   obj.direction,...
                                     'edgeColor',   edgeC{end - jj},...
                                     'legendInfo',  'off',...
                                     'visible',     obj.visible,...
                                     'side',        obj.side);

                        obj.children = [obj.children, p];

                    end

                end

            end

            % The negativ values
            for ii = 1:size(y1Neg,1)

                for jj = 0:size(y1Neg,2) - 1

                    colorTemp = obj.cData(end - jj,:);

                    if y1Neg(ii,end - jj) < 0

                        xTemp = [obj.xData(ii) - obj.barWidth/2; obj.xData(ii) + obj.barWidth/2];
                        x     = [xTemp(1);xTemp(1);xTemp(2);xTemp(2)];
                        y     = [scaleFactor; y1Neg(ii,end - jj); y1Neg(ii,end - jj); scaleFactor];
                        y     = y + sum(y1Neg(ii,1:end - jj - 1));

                        if obj.shaded(ii,end - jj)
                            if obj.blend
                                colorTemp = nb_alpha(colorTemp,obj.shadeColor,obj.alpha1,obj.alpha2);
                            else
                                colorTemp = [colorTemp; obj.shadeColor]; %#ok
                            end
                        end

                        p = nb_patch(x,y + baseV(ii),colorTemp,...
                                     'parent',      par,...
                                     'lineWidth',   obj.lineWidth,...
                                     'lineStyle',   lineS{end - jj},...
                                     'direction',   obj.direction,...
                                     'edgeColor',   edgeC{end - jj},...
                                     'legendInfo',  'off',...
                                     'visible',     obj.visible,...
                                     'side',        obj.side);

                        obj.children = [obj.children, p];

                    end

                end

            end
                        
        end
        
        %{
        -------------------------------------------------------------------
        The method which does the plotting
        -------------------------------------------------------------------
        %}
        function plotBarsFast(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            deleteChildren(obj);
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,1) == 1
                obj.xData = obj.xData';
            end
            
            if size(obj.yData,1) == 1 && size(obj.xData,1) ~= 1
                obj.yData = obj.yData';
            end
            
            if size(obj.xData,2) > 1
                error([mfilename ':: The ''xData'' property must be a vector, but is a matrix with size; ' int2str(size(obj.xData,1)) 'x' int2str(size(obj.xData,2))])
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
            
            if isnumeric(obj.edgeColor) && size(obj.edgeColor,1) > 1
                if size(obj.edgeColor,1) ~= size(obj.yData,2)
                    error([mfilename ':: The property ''edgeColor'' has not the proper size. Must be ' int2str(size(obj.yData,2)) ' x 3.']);
                end
                sY    = size(obj.yData,2);
                edgeC = cell(1,sY);
                for ii = 1:sY
                    edgeC{ii} = obj.edgeColor(ii,:);
                end
            elseif ischar(obj.edgeColor) || isnumeric(obj.edgeColor)
                sY    = size(obj.yData,2);
                edgeC = cell(1,sY);
                for ii = 1:sY
                    edgeC{ii} = obj.edgeColor;
                end
            else 
                if length(obj.edgeColor) ~= size(obj.yData,2)
                    error([mfilename ':: The property ''edgeColor'' has not the proper size. '....
                        'Is 1x' int2str(length(obj.edgeColor)) ' or ' int2str(length(obj.edgeColor)) 'x1, but must be 1x' int2str(size(obj.yData,2))])     
                else
                    edgeC = obj.edgeColor;
                end
            end
            
            sY      = size(obj.yData,2);
            lineSty = cell(1,sY);
            for ii = 1:sY
                lineSty{ii} = obj.lineStyle;
            end
            lineS         = obj.lineStyle;
            obj.lineStyle = lineSty;
                
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
            if ~isempty(obj.sumTo) && ~strcmpi(obj.style,'dec')               
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
            
            if strcmpi(obj.style,'grouped')
                barW = 1;
            else
                barW = obj.barWidth;
            end
            
            if strcmpi(obj.style,'dec')
                st = 'stacked';
            else
                st = obj.style;
            end
            
            %--------------------------------------------------------------
            % Start plotting
            %--------------------------------------------------------------
            try
            
                % Positive values
                yPos                          = obj.yData;
                yPos(obj.yData<obj.baseValue) = obj.baseValue;
                childsPos = bar(obj.xData,yPos,...
                    'barLayout',    st,...
                    'baseValue',    obj.baseValue,...
                    'barWidth',     barW,...
                    'lineStyle',    lineS,...
                    'lineWidth',    obj.lineWidth,...
                    'parent',       par,...
                    'showBaseLine', 'off',...
                    'visible',      obj.visible);
                
                % Negative values
                yNeg                          = obj.yData;
                yNeg(obj.yData>obj.baseValue) = obj.baseValue;
                childsNeg = bar(obj.xData,yNeg,...
                    'barLayout',    st,...
                    'baseValue',    obj.baseValue,...
                    'barWidth',     barW,...
                    'lineStyle',    lineS,...
                    'lineWidth',    obj.lineWidth,...
                    'parent',       par,...
                    'showBaseLine', 'off',...
                    'visible',      obj.visible);
                
                obj.children = [childsPos,childsNeg];
                for ii = 1:size(obj.yData,2)
                    edgeColorII = edgeC{ii};
                    if strcmpi(edgeColorII,'same')
                        edgeColorII = obj.cData(ii,:);
                    end
                    set(childsPos(ii),...
                        'faceColor',obj.cData(ii,:),...
                        'edgeColor',edgeColorII);
                    set(childsNeg(ii),...
                        'faceColor',obj.cData(ii,:),...
                        'edgeColor',edgeColorII);
                end
                
                % Add the line representing the sum of the stacked bars
                %----------------------------------------------------------
                if strcmpi(obj.style,'dec')
                    
                    if isempty(obj.lineObj)
                        baseM       = obj.baseValue(:,ones(1,size(data,2)));
                        tot         = sum(data - baseM,2) + obj.baseValue;
                        obj.lineObj = nb_line(obj.xData,tot,...
                                           'parent',obj.parent,...
                                           'lineWidth',obj.lineWidth);
                    else
                        set(obj.lineObj,'parent',obj.parent,'lineWidth',obj.lineWidth);
                    end
                    
                else
                    if ~isempty(obj.lineObj)
                        obj.lineObj.deleteOption = 'all';
                        delete(obj.lineObj);
                        obj.lineObj = [];
                    end
                end
                
            catch Err
                
                if ~isempty(obj.children)
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
                    obj.baseline = nb_line(obj.xData,obj.baseValue,'parent',obj.parent,'visible',obj.visible,'side',obj.side,'lineWidth',obj.lineWidth);
                else
                    set(obj.baseline,'xData',obj.xData,'yData',obj.baseValue,'parent',obj.parent,'visible',obj.visible,'side',obj.side,'lineWidth',obj.lineWidth);
                end
                
            end
              
        end
        
    end
    
    %======================================================================
    % Static methods
    %======================================================================
    methods (Static=true)
       
           
    end
    
end
        
