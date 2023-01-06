classdef nb_radar < nb_plotHandle & nb_notifiesMouseOverObject
% Syntax:
%     
% obj = nb_radar(xData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a Class for making radar plots
% 
% This class will make the radar plot automatically fit the axes it
% is plot into.
%
% I recommend to use the nb_* classes for the legend, titles and so
% on.  
%     
% Constructor:
%     
%     nb_radar(xData)
%     nb_radar(xData,'propertyName',propertyValue,...)
%     handle = nb_radar(xData,'propertyName',propertyValue,...)    
%  
%     Input:
% 
%     - xData    : The data to plot. size(xData,1) = number of 
%                  variables and size(xData,2) = number of 
%                  observations
% 
%     Optional input:
%
%     - varargin : 'propertyName',propertyValue,...
% 
%     Output:
% 
%     - obj      : An object of class nb_radar (handle).
%     
%     Examples:
% 
%     nb_radar(xData)
%     nb_radar(xData,'propertyName',propertyValue,...)
%     handle = nb_radar(xData,'propertyName',propertyValue,...)  
%     radar = nb_radar([1,2; 2,4; 3,5; 2,1; 3,4; 2,5],...
%                   'numberOfIsoLines',10);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % A 1x3 double with the RGB color or a string 
        % with the color name of the axes 
        axesColor        = [0 0 0]; 
        
        % The axes max limit. Must be a double with size 
        % size(xData,1)x1
        axesLimMax       = [];       
        
        % The axes min limit. Must be a double with size 
        % size(xData,1)x1
        axesLimMin       = [];   
        
        % The axes line width. As a scalar.
        axesLineWidth    = 1;             
        
        % The colors of the plotted data. Must be of 
        % size; length(xData) x 3. (Double with the RGB
        % colors). Or a cellstr with the color names.
        % Must be of size 1 x length(xData). See the 
        % method interpretColor of the nb_plotHandle 
        % class for more on the supported color names.
        cData            = [];  
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption     = 'only'; 
        
        % The color of the font of the labels. Either
        % a 1x3 double with the color of all the 
        % labels or a size(xData,1) x 3 with the color
        % of each label (RGB colors). Can also be a 
        % string with the color names to use on all 
        % labels or a cellstr with the color names
        % of each label. Size must be 1 x size(xData,1)
        fontColor        = [0 0 0];   
        
        % Name of the font used for the labels. As a string. 
        % 'arial' is default.
        fontName         = 'Arial';    
        
        % Size of the font used for the labels. As a scalar.
        fontSize         = 12;            
        
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
        
        % Weight of the font used for the labels. As a string.
        % 'normal' is default.
        fontWeight       = 'normal';      
        
        % A 1x3 double with the RGB color or a string 
        % with the color name of the isocurves 
        isoLineColor     = [0.1 0.1 0.1];
        
        % The line style of the isocurves. As a string.
        isoLineStyle     = '-';    
        
        % The line width of the isocurves. As a scalar.
        isoLineWidth     = 1;             
        
        % A cell array with the labels of the plot. Must have the 
        % same size as; size(xData,1). Each element of the cell 
        % array can consist of char with more lines. I.e. 
        % {'A string',char('In a char','with two lines'),...} 
        labels           = {};   
        
        % {'off'} : Not included in the legend. 'on' : included in 
        % the legend
        legendInfo       = 'on'; 
        
        % Line style of the plotted data. As a string or a cellstr 
        % with size size(xData,2).
        lineStyle        = '-';  
        
        % Line width of the plotted data. As a double.
        lineWidth        = 1.5;       
        
        % 'west' | 'east' | {'center'}. The location of the plot in 
        % the axes.
        location         = 'center'; 
        
        % The number of isocurves of the radar plot. Must be an
        % integer. Default is 10.
        numberOfIsoLines = 3;       
        
        % Rotate the radar. In radians. Must be a scalar. Default 
        % is 0.
        rotate           = 0;             
        
        % Sets the axes limits, so the radar plot is scaled 
        % properly. (Also set the size of the plotted radar). Must 
        % be a 1x2 double. Default is [2,1.25].
        scale            = [2,1.25];
        
        % Sets the visibility of the radar plot. {'on'} | 'off'.
        visible          = 'on';          
        
        % The data to plot. size(xData,1) = number of 
        % observations and size(xData,2) = number of 
        % variables
        xData            = [];           
        
    end
    
    %======================================================================
    % Protected properties of the object
    %======================================================================
    properties (Access=protected)
        
        % The children of this object. I.e. all the plotting object 
        % of this object
        children        = [];            
        
        % Which axes to plot on. Only the left axis is possible for this
        % class
        side            = 'left';         
        type            = 'line';
        
    end
    
    methods
        
        function set.axesColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The axesColor property must be a 1x3'...
                      ' double with the RGB color or a string with the'...
                      ' color name of the axes'])
            end
            obj.axesColor = value;
        end
        
        function set.axesLimMax(obj,value)
            if ~any(ismember(size(value),1))
                error([mfilename '::  The axes max limit must be a '...
                                 'double with size size(xData,1)x1'])
            end
            obj.axesLimMax = value;
        end
        
        function set.axesLimMin(obj,value)
            if ~any(ismember(size(value),1))
                error([mfilename '::  The axes min limit must be a '...
                                 'double with size size(xData,1)x1'])
            end
            obj.axesLimMin = value;
        end
        
        function set.axesLineWidth(obj,value)
            if ~isscalar(value)
                error([mfilename '::  The axes line width property must'...
                    ' be a scalar.'])
            end
            obj.axesLineWidth = value;
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
        
        
        function set.fontColor(obj,value)
            if ~nb_isColorProp(value,true)
                error([mfilename ':: The fontColor property must be a 1x3'...
                      ' double with the RGB color or a string with the'...
                      ' color name of the font'])
            end
            obj.fontColor = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontName property must be a'...
                      ' one line char with the font name.'])
            end
            obj.fontName = value;
        end
        
        function set.fontSize(obj,value)
            if ~isscalar(value)
                error([mfilename '::  The fontSize property must'...
                    ' be a scalar.'])
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
                error([mfilename ':: The fontWeight property must be a'...
                      ' one line char with the font size. ''normal''',...
                      ' is default.'])
            end
            obj.fontWeight = value;
        end
        
        function set.isoLineColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The isoLineColor property must be a 1x3'...
                      ' double with the RGB color or a string with the'...
                      ' color name of the isocurve.'])
            end
            obj.isoLineColor = value;
        end
        
        function set.isoLineStyle(obj,value)
            if ~nb_islineStyle(value)
                error([mfilename ':: The isoLineStyle property must be'...
                      ' a one line char with the line style.'])
            end
            obj.isoLineStyle = value;
        end
        
        function set.isoLineWidth(obj,value)
            if ~isscalar(value)
                error([mfilename '::  The iso line width property must'...
                    ' be a scalar.'])
            end
            obj.isoLineWidth = value;
        end
        
        function set.labels(obj,value)
            if ~iscellstr(value) && ~any(ismember(size(value),1))
                error([mfilename '::  The labels property must be a '...
                    ' cell array with the labels of each plot with size'...
                    ' size(xData,1).'])
            end
            obj.labels = value;
        end
        
        function set.legendInfo(obj,value)
            if ~~any(strcmp({'off','on'},value))
                error([mfilename '::  The legendInfo property must be '...
                      'either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
        end       
        
        function set.lineStyle(obj,value)
            if ~nb_islineStyle(value,true)
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
            if ~~any(strcmp({'west','east','center'},value))
                error([mfilename '::  The location property must be '...
                      'either ''west'', ''east'', or center.'])
            end
            obj.location = value;
        end    
    
        function set.numberOfIsoLines(obj,value)
            if ~nb_isScalarInteger(value)
                error([mfilename ':: The numberOfIsoLines property must be'...
                                 ' set to a scalar integer.'])
            end
            obj.numberOfIsoLines = value;
        end
        
        function set.rotate(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The rotate property must be'...
                                 ' given as a scalar double.'])
            end
            obj.rotate = value;
        end
      
         function set.scale(obj,value)
             if ~nb_isScalarInteger(value) && ~isa(value,'double')
                 error([mfilename ':: The scale property must be'...
                                  ' set to a scalar integer.'])
             end
             obj.scale = value;
         end               
        
        function set.visible(obj,value)
            if ~~any(strcmp({'on','off'},value))
                error([mfilename '::  The visible property must be '...
                      'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end    
    
        function set.xData(obj,value)
            if ~isa(value,'double') 
                error([mfilename ':: The xData property must be'...
                                 ' given as double.'])
            end
            obj.xData = value;
        end           
        
        function obj = nb_radar(xData,varargin)
            
            if nargin < 1
                xData = [1,1,1,1,1; 1 1 1 1 1; 1 1 1 1 1;  1 1 1 1 1;...
                         1 1 1 1 1;  1 1 1 1 1;  2 2 2 2 2];
            end
            
            % Assign the properties
            obj.xData   = xData;
            
            % Set the optional properties and plot
            obj.set(varargin);
            
        end
        
        varargout = set(varargin)
        
        varargout = get(varargin)
        
        function axesLineWidth = get.axesLineWidth(obj)
           axesLineWidth = nb_scaleLineWidth(obj,obj.axesLineWidth); 
        end
        
        function isoLineWidth = get.isoLineWidth(obj)
           isoLineWidth = nb_scaleLineWidth(obj,obj.isoLineWidth); 
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
            
            xlimit = [-obj.scale(1) obj.scale(1)];
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj) 
            
            ylimit = [-obj.scale(2) obj.scale(2)];
            
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
                
                ld(1,size(obj.xData,2)) = nb_legendDetails();
                for ii = 1:size(obj.xData,2) 
                    ld(1,ii).lineColor              = obj.cData(ii,:);
                    ld(1,ii).lineStyle              = obj.lineStyle{ii};
                    ld(1,ii).lineWidth              = obj.lineWidth;
                    ld(1,ii).lineMarker             = 'none';
                    ld(1,ii).lineMarkerEdgeColor    = 'auto';
                    ld(1,ii).lineMarkerFaceColor    = 'auto';
                    ld(1,ii).lineMarkerSize         = 9;
                    ld(1,ii).side                   = 'left';                    
                end
                
            else
                ld = [];
            end
            legendDetails = ld;
            
        end
        
    end
    
    methods (Hidden)
        function [x, y, angle] = getPointPositions(obj)
            [rows, cols] = size(obj.xData);
            radius       = obj.xData./obj.numberOfIsoLines;   
            angle        = (2*pi/rows) * ((rows:-1:1)'*ones(1,cols));
            angle        = angle + obj.rotate;
            [x, y]       = pol2cart(angle, radius);
        end
        
        function [x,y,value] = notifyMouseOverObject(obj, point)
        % point : current point in data units
            
            tolerance = 0.05;
            if any(abs(point) > 1 + tolerance)
                x     = [];
                y     = [];
                value = [];
                return;
            end
            x = point(1);
            y = point(2);
            
            % TODO: Cache this for performance?
            [X, Y] = obj.getPointPositions();
            
            % Find closest data point
            dist   = sqrt((X - x).^2 + (Y - y).^2);
            [~, i] = min(dist(:));
            [x, y] = ind2sub(size(dist), i);
            value  = obj.xData(x, y);
            if dist(x, y) > tolerance
                x     = [];
                y     = [];
                value = [];
                return;
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Plot the radar plot
        -------------------------------------------------------------------
        %}
        function plotRadar(obj)
            
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
            
            try
            
                %----------------------------------------------------------
                % Get the number of dimensions and points
                %----------------------------------------------------------
                [rows, cols] = size(obj.xData);

                %----------------------------------------------------------
                % Plot the axes
                %----------------------------------------------------------
                % Interpret the axes color
                if ischar(obj.axesColor) || iscell(obj.axesColor)
                    aColor = nb_plotHandle.interpretColor(obj.axesColor);
                else
                    aColor = obj.axesColor;
                end
                
                % Get coordinates
                angle  = (2*pi/rows)*(ones(2,1)*(rows:-1:1));
                angle  = angle + obj.rotate;
                radius = [0;1]*ones(1,rows);
                [x,y]  = pol2cart(angle, radius);
                hLine  = line(x, y,...
                             'lineWidth', obj.axesLineWidth,...
                             'color',     aColor,...
                             'parent',    axh,...
                             'visible',   obj.visible);

                % Exclude the lines from the legend          
                for i = 1:numel(hLine)
                    set(get(get(hLine(i),'Annotation'),'LegendInformation'),...
                        'IconDisplayStyle','off'); 
                end
                
                % Add them to the children
                obj.children = [obj.children, hLine'];

                %----------------------------------------------------------
                % Add the iso-curves
                %----------------------------------------------------------

                % Get coordinates of the iso-curves
                angle  = (2*pi/rows)*(ones(obj.numberOfIsoLines,1)*(rows:-1:1));
                angle  = angle + obj.rotate;
                radius = (linspace(0, 1, obj.numberOfIsoLines + 1)')*ones(1,rows);
                radius = radius(2:end,:);
                [x,y]  = pol2cart(angle, radius);
                
                % Interpret the iso line color
                if ischar(obj.isoLineColor) || iscell(obj.isoLineColor)
                    isoColor = nb_plotHandle.interpretColor(obj.isoLineColor);
                else
                    isoColor = obj.isoLineColor;
                end
                hLine = line([x, x(:,1)]', [y, y(:,1)]',...
                             'lineWidth', obj.isoLineWidth,...
                             'lineStyle', obj.isoLineStyle,...
                             'color',     isoColor,...
                             'parent',    axh,...
                             'visible',   obj.visible);         
                for i = 1:numel(hLine)
                    set(get(get(hLine(i),'Annotation'),'LegendInformation'),...
                        'IconDisplayStyle','off'); 
                end
                
                % Add them to the children
                obj.children = [obj.children, hLine'];

                %----------------------------------------------------------
                % Plot the data
                %----------------------------------------------------------
                if isempty(obj.cData) 
                    obj.cData = nb_plotHandle.getDefaultColors(cols);
                elseif isnumeric(obj.cData)
                    if size(obj.cData,2) ~= 3
                        error([mfilename ':: The ''cData'' property must be a Mx3 matrix with the rgb colors of the plotted data.'])
                    elseif size(obj.cData,1) ~= cols
                        error([mfilename ':: The ''cData'' property has not as many rows (' int2str(size(obj.cData,1)) ') '...
                                         'as the property ''xData'' has columns. (' int2str(cols) ')'])
                    end
                elseif iscell(obj.cData)
                    if length(obj.cData) ~= cols
                        error([mfilename ':: The cellstr array given by ''cData'' property has not same length (' int2str(length(obj.cData)) ') '...
                                         'as the property ''xData'' has columns. (' int2str(cols) ')'])
                    else
                        obj.cData = nb_plotHandle.interpretColor(obj.cData);
                    end
                elseif ischar(obj.cData)
                    if size(obj.cData,1) ~= cols
                        error([mfilename ':: The char given by ''cData'' property has not same number of rows (' int2str(size(obj.cData,1)) ') '...
                                         'as the property ''xData'' has columns. (' int2str(cols) ')'])
                    else
                        obj.cData = nb_plotHandle.interpretColor(obj.cData);
                    end
                else
                    error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])       
                end    
                
                % Get coordinates of the data
                if isempty(obj.axesLimMin)
                    obj.axesLimMin = min(obj.xData,[],2);
                end
                if isempty(obj.axesLimMax)
                    obj.axesLimMax = max(obj.xData,[],2);
                end
                [x, y] = obj.getPointPositions();
                x      = [x; x(1, :)];
                y      = [y; y(1, :)];

                % Check some plotting options
                if ischar(obj.lineStyle)
                    obj.lineStyle = cellstr(obj.lineStyle);
                end
                if length(obj.lineStyle) == 1
                    obj.lineStyle = repmat(obj.lineStyle,1,size(x,2));
                elseif length(obj.lineStyle) ~= size(x,2)
                    error([mfilename ':: The number size of the lineStyle input must match size(xdata,2).'])
                end
                
                % Plot them
                for ii = 1:size(x,2)      
                    h = line(x(:,ii), y(:,ii),...
                             'lineWidth',   obj.lineWidth,...
                             'lineStyle',   obj.lineStyle{ii},...
                             'parent',      axh,...
                             'color',       obj.cData(ii,:),...
                             'visible',     obj.visible);
                    
                    % Add each to the children
                    obj.children = [obj.children, h];
                end

                %----------------------------------------------------------
                % Insert axis labels
                %----------------------------------------------------------
                if isempty(obj.fontColor)
                    
                    obj.fontColor = [0 0 0];
                    
                elseif isnumeric(obj.fontColor)
                    
                    if size(obj.fontColor,1) == 1
                        obj.fontColor = repmat(obj.fontColor,[rows,1]);
                    elseif size(obj.fontColor,1) ~= rows
                        error([mfilenames ':: The font colors must have the same number of rows (' int2str(size(obj.fontColor,1)) ') '...
                                          'as the number of rows of the ''xData'' property. (' int2str(rows) ')']) 
                    end
                    
                elseif iscell(obj.fontColor)
                
                    if length(obj.fontColor) == 1
                        fcolor        = nb_plotHandle.interpretColor(obj.fontColor);
                        obj.fontColor = repmat(fcolor,[rows,1]);
                    elseif length(obj.fontColor) ~= rows
                        error([mfilename ':: The cellstr array given by ''fontColor'' property has not same length (' int2str(length(obj.fontColor)) ') '...
                                         'as the number of rows of the ''xData'' property. (' int2str(rows) ')'])
                    else
                        obj.fontColor = nb_plotHandle.interpretColor(obj.fontColor);
                    end

                elseif ischar(obj.fontColor)

                    if size(obj.fontColor,1) == 1
                        fcolor        = nb_plotHandle.interpretColor(obj.fontColor);
                        obj.fontColor = repmat(fcolor,[rows,1]);
                    elseif size(obj.fontColor,1) ~= rows
                        error([mfilename ':: The char given by ''fontColor'' property has not same number of rows (' int2str(size(obj.fontColor,1)) ') '...
                                         'as the number of rows of the ''xData'' property. (' int2str(rows) ')'])
                    else
                        obj.fontColor = nb_plotHandle.interpretColor(obj.fontColor);
                    end

                else

                    error([mfilename ':: The property ''fontColor'' doesn''t support input of class ' class(obj.cData)])       

                end    
                
                if ~isempty(obj.labels)
                    
                    for j = 1:rows
                        
                        [mx, my] = pol2cart( angle(1, j), 1.06);
                        
                        if mx < -0.1
                            alignment = 'right';
                        elseif mx > 0.1
                            alignment = 'left';
                        else
                            alignment = 'center';
                        end
                        
                        if my < -0.1
                            valignment = 'top';
                        elseif my > 0.1
                            valignment = 'bottom';
                        else
                            valignment = 'middle';
                        end
                        
                        t = text(mx, my, obj.labels{j},...
                                 'fontName',            obj.fontName,...
                                 'fontWeight',          obj.fontWeight,...
                                 'clipping',            'off',...
                                 'color',               obj.fontColor(j,:),...
                                 'horizontalAlignment', alignment,...
                                 'verticalAlignment',   valignment,...
                                 'parent',              axh,...
                                 'visible',             obj.visible);
                           
                        set(t,'fontUnits',obj.fontUnits);
                        set(t,'fontSize', obj.fontSize);     
                             
                        % Add each to the children
                        obj.children = [obj.children, t];                       

                    end
                    
                end
                
            catch Err
                
                % Try to figure out whats wrong
                if ~isempty(obj.labels)
                    if size(obj.labels,2) ~= size(obj.xData,1)
                        error([mfilename ':: The ''labels'' property must be a 1x' int2str(size(obj.xData,1)) ' cellstr array, but is ' int2str(size(obj.labels,1)) 'x'...
                                          int2str(size(obj.labels,2))])
                    end
                end
                
                % If not rethrow the MATLAB error
                rethrow(Err);
                
            end
            
            %--------------------------------------------------------------
            % Set some axes properties
            %---------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                % Update the axes given the plotted data
                obj.parent.addChild(obj);
                obj.parent.set('xTick',[],'yTick',[],'yTickRight',[]);
            else
                axis(axh,[-1.1,1.1,-1.1,1.1]);
                axis(axh,'square');
                axis(axh,'off');
            end
            
        end
        
    end
    
end
