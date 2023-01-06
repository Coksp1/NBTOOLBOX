classdef nb_pie < nb_plotHandle & nb_notifiesMouseOverObject
% Syntax:
%     
% obj = nb_pie(yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for making pie charts in 2D.
%     
% This class will make the pie chart automatically fit the axes of 
% the plot.
%  
% I recommend to use the nb_* classes for the legend, titles and so
% on.
%     
% Constructor:
%     
%     obj = nb_pie(yData,varargin)
% 
%     Input:
% 
%     - yData    : The data to plot. min(size(yData)) must be 1.
% 
%     Optional input:
%
%     - varargin : 'propertyName',propertyValue,...
% 
%     Output:
% 
%     - obj      : An object of class nb_pie (handle).
%     
%     Examples:
% 
%     nb_pie(yData) 
%     nb_pie(yData,'propertyName',propertyValue,...)
%     handle = nb_pie(yData,'propertyName',propertyValue,...)  
%     
% See also:
% pie, pie3
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties(SetAccess = protected)
    
        % The handles of all the children of the plot.
        children        = [];    
    
    end
    
    properties
        
        % Make the axes box visible ('on') or not ('off'). 'on' is default.
        axisVisible     = 'on';
        
        % A logical array with ones for the pies to bite. I.e. [0,0,1,0];
        % Must be of size 1 x nSlices.
        bite            = [];
        
         % The colors of the plotted data. Must be of size nSlices x 3.
        % (Double with the RGB colors), or a cellstr with the color 
        % names. Must be of size 1 x length(yData). See the method 
        % nb_plotHandle.interpretColor for more on the supported 
        % color names.
        cData           = [];   
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption    = 'only'; 
        
        % The color of the edge of the pies. Must be of size; 
        % 1 x 3. (Double with the RGB colors), or a one line char
        % with the color name. See the method nb_plotHandle.interpretColor 
        % for more on the supported color names.
        edgeColor       = [0 0 0];  
        
        % A logical array with ones for the pies to explode. I.e. 
        % [0,0,1,0]; Must be of size 1 x nSlices. 
        explode         = []; 
        
        % Color of labels. Must be double with size 1 x 3 (RGB colors),  
        % or a string with the name of the color. See the method 
        % nb_plotHandle.interpretColor for more on the supported color 
        % names.
        fontColor       = [0 0 0];
        
        % Name of the font used. Default is 'arial'.
        fontName        = 'Arial'; 
        
         % Font size of the text on the plot. Default is 12.
        fontSize        = 12;  
        
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
        
        % Font weight og the text on the plot. Default is 'normal'.
        fontWeight      = 'normal';
        
        % The labels of the pies, must be a cellstr 
        % with size; length(yData). If not given the 
        % labels will be the shares of each pie in 
        % percent.
        labels          = {};
        
        % If you not give the labels you can set the extension of the 
        % labels. Default i '%'. The extension will be added to the value  
        % of the data. If '%' is given the data will be in relative shares
        % in percent.
        labelsExtension = '%';  
        
        % {'off'} : Not included in the legend. 'on' : included in 
        % the legend.
        legendInfo      = 'on';  
        
        % Line style of the edge.
        lineStyle       = '-';
        
        % Line width of the edge.
        lineWidth       = 1.5;      
        
        % {'west'} | 'east' | 'center'. The location of the pie 
        % chart in the current axes.
        location        = 'west';  
        
        % Force there to be no labels of the pies.
        noLabels        = 0;      
        
        % Set the origo position. Default is to use the location property.
        % Where 'west' is [-0.5,0], 'center' is [0,0] and 'east' is 
        % [0.5,0]. Must either be empty or a 1x2 double.
        origoPosition   = [];
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'.  
        visible         = 'on';  
        
        % The data to plot. Must be a double vector of size 1 x nSlices or
        % nSlices x 1.
        yData           = [];
            
    end
    
    properties (Hidden=true)
        
        % Only '2D' is supported
        dimension       = '2D'; 
        
    end
    
    properties (SetAccess = protected)
        
        % Handles to the labels of the pie plot. As MATLAB text objects.
        labelHandles = [];
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
       
        changeDimension = 0;        % 1 if the dimension is being changed
        initialized     = 1;        % 1 if being initialized, otherwise 0
        side            = 'left';   % Which axes to plot on. Only the left axes is possible for this class
        type            = 'patch';
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
        function set.axisVisible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename '::  The axisVisible property must'...
                    ' either ''on'', or ''off'''])
            end
            obj.axisVisible = value;
        end 

        function set.bite(obj,value)
            if ~isa(value,'double')
                error([mfilename '::  The bite property must be given as'...
                      ' a double.'])
            end
            obj.bite = value;
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
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end        

        function set.dimension(obj,value)
            if ~strcmpi('2D',value)
                error([mfilename '::  Only ''2D'' is supported.'])
            end
            obj.dimension = value;
        end
        
        function set.edgeColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The edgeColor property must be set'...
                    ' to a valid color property.'])
            end
            obj.edgeColor = value;
        end        
        
        function set.explode(obj,value)
            if ~isa(value,'double') && ~islogical(value)
                error([mfilename ':: The explode property must be set'...
                    ' to a logical array.'])
            end
            obj.explode = value;
        end    
        
        function set.fontColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The fontColor property must be set'...
                    ' to a valid color property.'])
            end
            obj.fontColor = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontName property must be given'...
                    ' as a one line character array.'])
            end
            obj.fontName = value;
        end        
        
        function set.fontSize(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The fontSize property must be given'...
                    ' as a scalar double.'])
            end
            obj.fontSize = value;
        end                
        
        function set.fontUnits(obj,value)
            if ~any(strcmp({'points','normalized','inches','centimeters',...
                            'pixels'},value))
                error([mfilename '::  The fontUnits property must'...
                    ' either ''points'', ''normalized'',''inches''',...
                    '''centimeters'', or ''pixels'''])
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
        
        function set.labels(obj,value)
            if ~isa(value,'cell')
                error([mfilename ':: The labels property must be given'...
                    ' as a cellstring.'])
            end
            obj.labels = value;
        end
        
        function set.labelsExtension(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The labelsExtension property must be'...
                    ' given as a one line character array.'])
            end
            obj.labelsExtension = value;
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
        
        function set.location(obj,value)
            if ~any(strcmp({'west','east','center'},value))
                error([mfilename '::  The location property must be '...
                      'either ''west'', ''east'', or center.'])
            end
            obj.location = value;
        end
        
        function set.noLabels(obj,value)
            if ~nb_isScalarLogical(value)
                error([mfilename ':: The noLabels property must be given'...
                    ' as a logical.'])
            end
            obj.noLabels = value;
        end   
        
        function set.origoPosition(obj,value)
            if ~isnumeric(value)
                error([mfilename ':: The origoPosition property must be given'...
                    ' as a 1x2 double.'])
            end
            if ~(nb_sizeEqual(value,[1,2]) || isempty(value))
                error([mfilename ':: The origoPosition property must have size 1x2.'])
            end
            obj.origoPosition = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The visible property must be set to'...
                      ' either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
        
        function set.yData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be given'...
                    ' as a double.'])
            end
            obj.yData = value;
        end
        
%         function set.labelHandles (obj,value)
%             if ~
%                 error([mfilename ':: '])
%             end
%             obj.labelHandles  = value;
%         end         
        
        function obj = nb_pie(yData,varargin)
            
            if nargin < 1
                yData = [2,2,2,2];
            end
            
            % Assign the properties
            obj.yData   = nb_rowVector(yData);
            
            if size(obj.yData,1) ~= 1 && size(obj.yData,2) ~= 1
                error([mfilename ':: The ''yData'' property must be a double vector.'])
            end
            
            % Set some default settings
            obj.bite        = zeros(size(yData));
            obj.explode     = zeros(size(yData));
            
            % Set the optional properties and plot
            obj.set(varargin);
            
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
            xlimit = [-1.5 1.5];       
            % Maintain aspect ratio
            pos    = nb_getInUnits(obj.parent.axesHandle, 'Position', 'points');
            xlimit = xlimit * pos(3) / pos(4);        
        end
        
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj) %#ok  
            ylimit = [-1.5 1.5];
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
            
            if strcmpi(obj.legendInfo,'on')
                
                ld(1,size(obj.yData,2)) = nb_legendDetails();

                for ii = 1:size(obj.yData,2)
                    
                    ld(1,ii).patchColor         = obj.cData(ii,:);
                    ld(1,ii).patchDirection     = 'north';
                    ld(1,ii).patchEdgeColor     = obj.edgeColor;
                    ld(1,ii).patchEdgeLineWidth = 1;
                    ld(1,ii).patchEdgeLineStyle = '-';
                    ld(1,ii).patchFaceAlpha     = 1;
                    ld(1,ii).patchFaceLighting  = 'none';
                    ld(1,ii).side               = 'left';
                    ld(1,ii).type               = 'patch';
                    
                end
                
            else
                
                ld = [];    

            end
            
            legendDetails = ld;
            
        end
        
        function [x, y] = getOrigoPosition(obj)
            
            if ~isempty(obj.origoPosition)
                x = obj.origoPosition(1);
                y = obj.origoPosition(2);
                return
            end
            
            x = 0;
            y = 0;
            switch obj.location                 
                case 'west'                       
                    x = x - 0.5;
                case 'east'
                    x = x + 0.5;
            end
            
        end
        
        function [startAngle, endAngle] = getSliceAngle(obj, index)
            pieData    = obj.yData / sum(obj.yData);
            startAngle = pi/2 + sum(pieData(1:index-1)) * 2*pi;
            endAngle   = startAngle + pieData(index) * 2*pi;
        end
        
        function [x, y, angle] = getSlicePosition(obj, index, relativeAngle, relativeRadius)
            
            if nargin < 4
                relativeRadius = 0;
                if nargin < 3
                    relativeAngle = 0;
                end
            end
            
            [startAngle,endAngle] = obj.getSliceAngle(index);
            angle                 = startAngle + relativeAngle .* (endAngle - startAngle);
            angle                 = mod(angle, 2 * pi);
            [x, y]                = pol2cart(angle, 1 + relativeRadius);
            if obj.explode(index)
                [xExplode, yExplode] = pol2cart(mean([startAngle, endAngle]), .1);
                x = x + xExplode;
                y = y + yExplode;
            end
            
            [xOrigo,yOrigo] = obj.getOrigoPosition();
            x               = x + xOrigo;
            y               = y + yOrigo;
   
        end
  
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Plot the pie chart given the properties
        -------------------------------------------------------------------
        %}
        function plotPie(obj)
            
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
                axh        = obj.parent.plotAxesHandle;
            else
                if isa(obj.parent,'nb_axes')
                    axh = obj.parent.plotAxesHandle;
                else
                    axh = obj.parent;
                end
            end
            
            %--------------------------------------------------------------
            % Decide the default labels
            %--------------------------------------------------------------
            if isempty(obj.labels)
                findDefaultLabels(obj);
            end
            
            %--------------------------------------------------------------
            % Normalise data
            %--------------------------------------------------------------
            data = obj.yData;
            if sum( data ) > 1
                data = data / sum( data );
            end
            
            if ischar(obj.edgeColor)
                edgeC = nb_plotHandle.interpretColor(obj.edgeColor);
            else
                edgeC = obj.edgeColor;
            end
            
            %--------------------------------------------------------------
            % OK, let's do some plotting!
            %--------------------------------------------------------------       
            set( ancestor( axh, 'figure' ), 'Renderer', 'painters' );

            try
            
                for ii = 1:length(data)
                    
                    relativeAngles = linspace(0, 1, max(1, ceil(360 * data(ii))) + 1);
                    [xx, yy]       = obj.getSlicePosition(ii, relativeAngles); 
                    [xTip, yTip]   = obj.getSlicePosition(ii, 0, -1);
                    xx             = [xTip xx xTip]; %#ok<AGROW>
                    yy             = [yTip yy yTip]; %#ok<AGROW>
                    
                    % Create the patches
                    color = ii;
                    s = patch(xx, ...
                        yy, ...
                        color(:,1), ...
                        'Parent',    axh,...
                        'edgeColor', edgeC,...
                        'lineWidth', obj.lineWidth,...
                        'lineStyle', obj.lineStyle,...
                        'clipping',  'off',...
                        'visible',   obj.visible);
                    
                    obj.children = [obj.children, s];
                    
                    % Label
                    if ~obj.noLabels
                        
                        % Find the label location
                        labelDistance           = 0.2;
                        [xLabel, yLabel, angle] = obj.getSlicePosition(ii, 0.5, labelDistance);
                        if angle < pi/4
                            hAlignment = 'left';
                            vAlignment = 'middle';
                        elseif angle < pi*3/4
                            hAlignment = 'center';
                            vAlignment = 'bottom';
                        elseif angle < pi*5/4
                            hAlignment = 'right';
                            vAlignment = 'middle';
                        elseif angle < pi*7/4
                            hAlignment = 'center';
                            vAlignment = 'top';
                        else
                            hAlignment = 'left';
                            vAlignment = 'middle';
                        end
                    
                        if ischar(obj.fontColor) || iscell(obj.fontColor)
                            fColor = nb_plotHandle.interpretColor(obj.fontColor);
                        else
                            fColor = obj.fontColor;
                        end                      
                        
                        t = text( xLabel, yLabel, obj.labels{ii}, ...
                                  'fontName',             obj.fontName,...
                                  'fontWeight',           obj.fontWeight, ...
                                  'color',                fColor,...
                                  'horizontalAlignment',  hAlignment, ...
                                  'verticalAlignment',    vAlignment, ...
                                  'parent',               axh, ...
                                  'clipping',             'off',...
                                  'visible',              obj.visible);
                         obj.labelHandles(ii) = t;
                         set(t,'fontUnits',obj.fontUnits);
                         set(t,'fontSize', obj.fontSize);
                         obj.children = [obj.children, t];
                    end

                end

                %----------------------------------------------------------
                % Set the colors
                %----------------------------------------------------------
                if isempty(obj.cData)
                    
                    obj.cData = nb_plotHandle.getDefaultColors(length(obj.yData));
                    
                elseif isnumeric(obj.cData)
                    
                    if size(obj.cData,1) ~= length(obj.yData) || size(obj.cData,2) ~= 3
                        error([mfilename ':: The ''cData'' property must be of size ' int2str(length(obj.yData)) 'x3. With the RGB colors.'])
                    end
                    
                elseif iscell(obj.cData)
                    
                    if length(obj.cData) ~= length(obj.yData)
                        error([mfilename ':: The cellstr array given by ''cData'' property has not same length (' int2str(length(obj.cData)) ') as the length of the property ''yData''. (' int2str( length(obj.yData)) ')'])
                    else
                        obj.cData = nb_plotHandle.interpretColor(obj.cData);
                    end
                    
                elseif ischar(obj.cData)
                    
                    if size(obj.cData,1) ~= length(obj.yData)
                        error([mfilename ':: The char given by ''cData'' property has not same number of rows (' int2str(size(obj.cData,1)) ') as the length of the property ''yData''. (' int2str( length(obj.yData)) ')'])
                    else
                        obj.cData = nb_plotHandle.interpretColor(obj.cData);
                    end

                else

                    error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])   
                    
                end
                colormap(axh, obj.cData);

                %----------------------------------------------------------
                % Set the visual effects 
                if obj.initialized  
                    set(axh,'clipping','off'); 
                end
                lighting(axh, 'none');

                %----------------------------------------------------------
                obj.initialized     = 0;
                obj.changeDimension = 0;
                
                %----------------------------------------------------------
                % Add to the parent (If the parent is a nb_axes handle)
                %----------------------------------------------------------
                if isa(obj.parent,'nb_axes')                   
                    % Update the axes given the plotted data
                    obj.parent.addChild(obj);
                    obj.parent.set('xTick',[],'yTick',[],'yTickRight',[],'axisVisible',obj.axisVisible); 
                end
                
            catch Err
                
                % Try to find out whats wrong
                testProperties(obj);
                
                % Else throw the MATLAB error
                rethrow(Err)
                
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
        Test for wrongly given properties
        -------------------------------------------------------------------
        %}
        function testProperties(obj)
            
            if size(obj.yData,1) ~= 1 && size(obj.yData,2) ~= 1
                error([mfilename ':: The ''yData'' property must be a double vector.'])
            end
            
            if length(obj.yData) ~= length(obj.bite)
                error([mfilename ':: The ''bite'' property and the ''yData'' property must have the same size.'])
            end
            
            if length(obj.yData) ~= length(obj.explode)
                error([mfilename ':: The ''explode'' property and the ''yData'' property must have the same size.'])
            end
            
            if length(obj.yData) ~= length(obj.labels)
                error([mfilename ':: The ''labels'' property and the ''yData'' property must have the same size.'])
            end
            
            if ~ischar(obj.labelsExtension) || size(obj.labelsExtension,2) > 1
                error([mfilename ':: The ''labelsExtension'' property must be a string'])
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the default labels
        -------------------------------------------------------------------
        %}
        function findDefaultLabels(obj) 
            
            if isempty(obj.labelsExtension)
                obj.labels = cellstr(num2str(obj.yData'));
            else

                if strcmp(obj.labelsExtension,'%')
                    temp = obj.yData;
                    tot  = sum(temp,2);
                    tot  = repmat(tot,[1,size(temp,2),1]);
                    temp = temp./tot;
                    temp = round(temp*10000)/100;
                    temp = cellstr(num2str(temp'));
                else
                    temp = round(obj.yData*100)/100;
                    temp = cellstr(num2str(temp'));
                end

                for jj = 1:size(temp,1)   
                    temp{jj} = [temp{jj},' ',obj.labelsExtension];
                end

                obj.labels = temp;

            end
            
        end
        
    end
    
    methods(Hidden=true)
        
        function [x,y,value] = notifyMouseOverObject(obj, point)
        % point : current point in data units
        
            [xOrigo, yOrigo] = obj.getOrigoPosition();
            point = point - [xOrigo, yOrigo];
            
            if any(abs(point) > 1)
                x = [];
                y = [];
                value = [];
                return;
            end
            
            angle = cart2pol(point(1), point(2));
            angle(angle < pi/2) = angle(angle < pi/2) + 2*pi;
            
            pieData = obj.yData / sum(obj.yData);
            dividingAngles = [pi/2, pi/2 + 2*pi * cumsum(pieData)];
            
            x = 1;
            y = find(angle > dividingAngles, 1, 'last');
            value = obj.yData(x, y);
            
        end
        
    end
    
    methods (Static=true)
          
    end
    
end
