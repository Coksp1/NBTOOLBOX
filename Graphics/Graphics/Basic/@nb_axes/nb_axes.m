classdef nb_axes < handle
% Syntax:
%     
% obj = nb_axes(varargin)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% This is a class for making plot axes.
%     
% This class does not supports all the normal axes properties
% through the set and get methods of this class, but the most
% important ones.
%     
% But it is possible to use the set and get methods of the 
% MATLAB axes class on the properties axesHandle and 
% axesHandleRight of this class after constructing a nb_axes
% object.
%     
% - This class supports y-axes on both sides
% - Some extra added functionalites:
%    > Shaded background
%    > Set the space between each tick marks of both the 
%      y-axis and x-axis
%         
% Caution : This way of making axes is not stable when using 
%           the normal MATLAB plotting commands, so I recommend
%           to use the "nb" plotting classes:
%               
%           > nb_area
%           > nb_bar
%           > nb_hbar
%           > nb_highlight
%           > nb_horizontalLine
%           > nb_line
%           > nb_patch
%           > nb_pie
%           > nb_plot
%           > nb_radar
%           > nb_scatter
%           > nb_plotComb
%           > nb_verticalLine
%        
% I also strongly recommend to use the nb_axes object as the
% parent of the listet classes above. The default is to use
% a nb_axes object as the parent for these classes.
%               
% The axes will automatically adjust given the children of the
% nb_axes object. But it is also possible to freeze the axes 
% options if you set the update property to 'off'.
% 
% Titles of axes:
%
% You must use the handle you get when intializing the nb_axes  
% object as the parent property of the nb_title class. I.e:
%             
%  > ax = nb_axes();
%    nb_title('A title','parent',ax)
%         
%  > nb_title('A title') WILL NOT WORK!
%  
% Lables on the axes:
%
% You must use the handle you get when intializing the nb_axes  
% object as the parent property of the nb_yLabel class. I.e:
%               
% > ax = nb_axes();
%   nb_yLabel(''A y-axis label'','parent',ax)
%         
% > nb_yLabel(''A y-axis label'') WILL NOT WORK!
%         
% It is also possible to decide which axis to place the label on,
% i.e. 'right' or 'left', by the property side. For more see the
% documentation of the nb_ylabel class.
%         
% The xLabel can be set in the same way as the yLabel, but you 
% do not have the side option. 
%     
% Constructor:
%     
%     nb_axes
%     nb_axes('propertyName',propertyValue,...)
%     ax = nb_axes('propertyName',propertyValue,...) 
%     
%     Input:
%         
%       - varargin : ...,'propertyName',propertyValue,... 
%
%                    Support most the inputs to the MATLAB axes 
%                    class for the left axes, but some extra 
%                    options is available:     
%         
%                    Right axis options:
%                    > 'yDirRight'     : Direction of the axes on 
%                                        the right
%                    > 'yLabelRight'   : The y-axis label of the 
%                                        plot
%                    > 'yLimRight'     : y-axis limit of the right
%                                        axes
%         
%                    Shaded background options:
%                    > 'shading'  : {'none'} or 'grey'
%     
%     Output:
%
%       - obj : A nb_axes handle (object). Wich can be given as 
%               the parent for the nb_* plotting classes
%         
%       A plotted axes in the current figure or newly made figure
%     
%     Examples:
%     
%     ax = nb_axes('position',[0.13 0.11 0.775 0.815],...
%                  'xLim',[0,1],'yLim',[0.1]);
%     
%     same as 
%     
%     ax = nb_axes
%     
% See also: 
% axes      
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    %======================================================================
    % The properties of the class
    %======================================================================
    properties (SetAccess=protected)
        
        % A MATLAB axes object (left axes of the plot)
        axesHandle              = []; 
        
        % A MATLAB axes object (right axes of the plot)
        axesHandleRight         = []; 
        
        % A MATLAB axes object (Where the axes labels are plotted)
        axesLabelHandle         = [];
        
        % All the "nb" plotting objects of the this axes object.
        children                = {};    
        
        % The nb_image object associated with this axes. See the
        % nb_image class.
        imageChild              = [];
        
        % The handle to do the plotting on. Has no axis. (When 
        % plotting on the left axes).
        plotAxesHandle          = [];
        
        % The handle to do the plotting on. Has no axis. (When 
        % plotting on the right axes)
        plotAxesHandleRight     = [];   
        
        % Axes of the shading
        shadingAxes             = []; 
        
        % The text objects of the y-axis tick labels (left)
        yTickLabelObjects       = []; 
        
        % The text objects of the y-axis tick labels (right)
        yTickLabelRightObjects  = [];
        
    end
    
    properties
          
        % Set to a scalar double to align a base value for the left and 
        % right axes 
        alignAxes               = [];
        
        % A cell with annotation objects
        annotations             = {};
        
        % If the axis of the plot should be on or off. {'on'} | 
        % 'off' 
        axisVisible             = 'on';                    
        
        % {'none'} | ColorSpec ; Color of the axes back planes. 
        % Setting this property to none means that the axes is 
        % transparent and the figure color shows through. A 
        % ColorSpec is a three-element RGB vector or one of the 
        % MATLAB predefined names. Note that while the default
        % value is none, the matlabrc.m startup file might set the 
        % axes Color to a specific color. If the 'shading' property 
        % is given this option will be overrunned.
        color                   = [1,1,1];
        
        % Sets the colormap used by the nb_image class if the object
        % only plotting a image of one page. Must be given as n x 3
        % double or a one line char with the path to a MAT file
        % containing the colormap. It will also set the colors used for 
        % the nb_gradedFanChart and nb_heatmap classes.
        %
        % For an example of a supported MAT file see:
        % - ...\Examples\Graphics\colorMapNB.mat
        colorMap                = [];
        
        % Either char(173) (dash), char(8211) (en-dash) or char(8212) 
        % (em-dash). char(8211) is default.
        dashType                = char(8211);
        
        % {'all'} | 'only'. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object. 
        deleteOption            = 'only';
        
        % Set it to fast implementation, but where it may be a loss of
        % functionality.
        fast                    = false;
        
        % The method used to find the limits of the axes. 1 | 2 | 
        % 3 | {4}. Default is to let MATLAB plot function find them                   
        findAxisLimitMethod     = 4;  
        
        % The font name used on the text of the axes.
        fontName                = 'arial';  
        
        % The font size used on the text of the axes. Only the 
        % x-tick and y-tick labels. See also fontSizeX
        fontSize                = 12;                       
        
        % The font size used on the text of the x-axis. I.e. the 
        % x-tick labels. If empty (default) the fontSize property is used.
        fontSizeX               = [];  
        
        % {'points'} | 'normalized' | 'inches'    
        % | 'centimeters' | 'pixels'
        % 
        % Font size units. MATLAB uses this 
        % property to determine the units used 
        % by the fontSize property.
        % 
        % normalized - Interpret FontSize as a 
        % fraction of the height of the parent  
        % axes. When you resize the axes, 
        % MATLAB modifies the screen 
        % fontSize accordingly.
        % 
        % pixels, inches, centimeters, and  
        % points: Absolute units. 1 point = 
        % 1/72 inch.
        fontUnits               = 'points'; 
        
        % The font weight used on the text of the axes. Only the 
        % x-tick and y-tick labels
        fontWeight              = 'normal';
        
        % 'on' | {'off'} ; If 'on' grid lines will be added
        grid                    = 'off';                    
        
        % As a 1x3 double. Sets the color of the axes major grid lines. 
        gridColor               = [0.1500,0.1500,0.1500];
         
        % '-' | '--' | {':'} | '-.' | 'none'. Line style used to 
        % draw grid lines. The line style is a string consisting of 
        % a character, in quotes, specifying solid lines (-), 
        % dashed lines (--), dotted lines(:), or dash-dot lines 
        % (-.). 
        gridLineStyle           = '--';  
        
        % Here will all the highlighted area handles be stored.
        highLighted             = {};                       
        
        % Here will all of the nb_horizontalLine objects of this 
        % axes be stored. This will make it possible to  
        % automatically fit the horizontal line objects to the axes 
        horizontalLine          = {};  
        
        % The number format on th y-axis is different for different 
        % languages. Either 'norsk' | {'english'}.
        language                = 'english';  
        
        % The legend of the axes, given as an nb_legend object.
        legend                  = [];
        
        % Sets the line width of the axes. Default is 0.5.
        lineWidth               = 0.5;
        
        % {'auto'} | 'manual' . If 'manual' the axis limits will no 
        % longer update themself automatically.
        limMode                 = 'auto'; 
        
        % Indicate if the font when fontUnits is set to 'normalized'
        % should be normalized to the axes ('axes') or to the
        % figure ('figure'), i.e. the default axes position 
        % [0.1 0.1 0.8 0.8]. Default is 'axes'.
        normalized              = 'axes';
        
        % The parent, as a nb_figure object.
        parent                  = [];                 
        
        % Set the plot box aspect ratio. Must be given as a
        % 1x3 double [ax,ay,az]. Default is empty, which means
        % the aspect ratio is given by the figure aspect ratio.
        plotBoxAspectRatio      = [];
        
        % Sets the precision/format of the rounding of number on the axes.
        %
        % See the precision input to the nb_num2str function. Default is
        % [], i.e. to call num2str without additional inputs.
        precision               = [];
        
        % Sets the orientation of the axes. Either 'vertical'  
        % (default) | 'horizontal'. 
        % 
        % Caution : The y-axes are still the right and the left  
        %           axes, and the x-axes are still the top bottom 
        %           axes.
        % 
        % Caution : The properties xTickLabelAlignment,
        %           xTickLabelLocation, xTickLocation, and all the
        %           properties which sets how the y-axis on the 
        %           right side are plotted are not supported when
        %           this property is set to 'horizontal'.
        orientation             = 'vertical';
        
        % Scale line width with this factor instead of the default scaling.
        % only when scaleLineWidth is set to true.
        scaleFactor         = [];
        
        % Scale line width to axes height. true or false (default).
        %
        % Caution: If you change the height of the axes you need to
        %          run an update on the children of the axes to make
        %          the line adjust.
        scaleLineWidth      = false;
        
        % The shading option of the axes background:
        % - 'grey' : Shaded grey background 
        % - 'none' : Background color given by the color property.
        % - A n x m x 3 double with the background color. n is the
        % number of horizontal pixels, m is the number of vertical
        % pixels and 3 means the RGB colors.
        shading                 = 'none'; 
        
        % {'in'} | 'out'. Direction of tick marks
        tickDir                 = 'in';
        
        % Tick length in normalized units. As a 1x2 double.
        tickLength              = [0.015,0.015];
        
        % The handle to the title placed right above the axes. An 
        % nb_title handle. 
        title                   = [];                       
        
        % Sets the uicontextmenu handle related to the this object 
        UIContextMenu           = [];
        
        % Units of the position property. Default is 'normalized'.
        units                   = 'normalized';
        
        % If you want to make it possible to add children to the 
        % axes without updating the axes. This could be important 
        % for speed, when plotting more object in one axes. 
        % Either {'on'} | 'off'.
        update                  = 'on';
        
        % Here will all of the nb_verticalLine objects of this axes 
        % be stored. This will make it possible to automatically 
        % fit the vertical line objects to the axes
        verticalLine            = {};  
        
        % {'on'} | 'off'. Sets the visibility of the axes and all 
        % its children.
        visible                 = 'on';
        
        % A nb_xLabel handle (object) of the y-axis label (both or 
        % only left). Use the nb_xLabel command.
        xLabel                  = [];  
        
        % The limit of the x-axis. As a 1x2 double.
        xLim                    = [];            
        
        % The offset of the x-axis tick marks.
        xOffset                 = 0.04;  
        
        % Sets the scale of the x-axis. {'linear'} | 'log'.
        xScale                  = 'linear';   
        
        % The tick marks location.
        xTick                   = []; 
        
        % The labels of the tick marks. Either a cellstr array or a 
        % double vector
        xTickLabel              = {};                       
        
        % Set the interpreter of the x-axis tick labels. {'text'}, 'none' 
        % or 'latex'.
        xTickLabelInterpreter   = 'tex';
        
        % The location of the x-axis tick marks labels.
        % Either {'bottom'} | 'top' | 'baseline'. 
        % 'basline' will only work in combination with
        % with the xtickLocation property set to a
        % double with the basevalue.  
        xTickLabelLocation      = 'bottom';    
        
        % The alignment of the x-axis tick marks
        % labels. {'normal'} | 'middle'
        xTickLabelAlignment     = 'normal';
        
        % The location of the x-axis tick marks.
        % Either {'bottom'} | 'top' | double. If given 
        % as a double the tick marks will be placed at
        % this value (where the number represent the 
        % y-axis value).
        xTickLocation           = 'bottom'; 
        
        % The text objects of the x-axis tick labels. 
        xTickLabelObjects       = [];
        
        % The rotation of the x tick marks. Specify values of 
        % rotation in degrees (positive angles cause 
        % counterclockwise rotation).
        xTickRotation           = 0;  
        
        % Sets the visibility of the x-axis tick marks. 1 visible 
        % and 0 invisible.  
        xTickVisible            = 1;   
        
        % {'normal'} | 'reverse'. The direction of the y-axis (both 
        % or only left)
        yDir                    = 'normal';   
        
        % {'normal'} | 'reverse'. The direction of the y-axis (only 
        % right)
        yDirRight               = 'normal';   
        
        % The nb_yLabel handle (object) of the y-axis labels (only 
        % left). 
        yLabel                  = []; 
        
        % The nb_yLabel handle (object) of the y-axis labels (only 
        % right). 
        yLabelRight             = [];      
        
        % The limit of the y-axis (both or only left). Default 
        % limits is [0 1], on both axes.
        yLim                    = [0,1];                     
        
        % The limit of the y-axis (only right). As long as there 
        % is not plotted any nb_* plotting objects on this axes 
        % this property will not be used, but of course if you set 
        % it.
        yLimRight               = [];                       
          
        % The offset of the y-axis tick marks 
        yOffset                 = 0.01; 
        
        % Sets the scale of the left y-axis (or both if nothing is 
        % plotted on the right axes). {'linear'} | 'log'.
        yScale                  = 'linear';   
        
        % Sets the scale of the right y-axis. {'linear'} | 'log'.
        yScaleRight             = 'linear'; 
        
        % The tick marks location (both or only left)
        yTick                   = [];  
        
        % The tick marks location (only right)
        yTickRight              = []; 
        
        % The labels of the tick marks (both or only left). Either
        % a cellstr array or a double vector
        yTickLabel              = {}; 
        
        % Set the interpreter of the y-axis tick labels. {'text'}, 'none' 
        % or 'latex'.
        yTickLabelInterpreter   = 'tex';
        
        % The labels of the tick marks (only right). Either a 
        % cellstr array or a double vector
        yTickLabelRight         = {}; 
        
        % Sets the visibility of the y-axis tick marks. 1 visible 
        % and 0 invisible.
        yTickVisible            = 1;                        
        
        %------------------------------------------------------------------
        % Properties which is not settable through the set method
        %------------------------------------------------------------------
        
        % Not settable
        tickObjects         = [];
        
        % Not settable
        xLimSet             = 0;
        
        % Not settable
        xTickSet            = 0;
        
        % Not settable
        xTickLabelSet       = 0;
        
        % Not settable
        yLimSet             = 0;
        
        % Not settable
        yLimRightSet        = 0;
        
        % Not settable
        yTickSet            = 0;
        
        % Not settable
        yTickRightSet       = 0;
        
        % Not settable
        yTickLabelSet       = 0;
        
        % Not settable
        yTickLabelRightSet  = 0;  
        
    end
    
    %======================================================================
    % The protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        % Stores the original position of axes set by the user before it
        % got adjusted by legend placement.
        originalPosition = [0.1 0.1 0.8 0.8];
        
        % Handle to the image plotted in this axes object.
        imageHandle      = [];
        
        % Stores the internal position of axes.
        internalPosition = [0.1 0.1 0.8 0.8];
        
        % The listeners to this object.
        listeners        = [];
        
    end
    
    %======================================================================
    % Dependent properties of the class
    %======================================================================
    properties (Dependent=true)
    
        % Position of axes. Specifies a rectangle that locates the 
        % axes within its parent container (figure or uipanel). The 
        % vector is of the form: [left bottom width height], where 
        % left and bottom define the distance from the lower-left 
        % corner of the container to the lower-left corner of the 
        % rectangle. width and height are the dimensions of the 
        % rectangle. The Units property specifies the units for
        % all measurements.
        %
        % Caution: If legend is placed outside the axes with some of the
        %          provided location property the axes will scale down
        %          accordingly. In this case this property stores the
        %          original position. See the axesHandlePosition property
        %          to get the corrected position (in normalized uints only)
        position 
        
    end
        
    %======================================================================
    % Events of class
    %======================================================================
    events
       
       mouseOverObject
       
    end
    
    %======================================================================
    % The methods of the class
    %======================================================================
    methods
        
        function obj = nb_axes(varargin)
            
            % Set the axes properties
            obj.set(varargin{:});
            
        end
        
        varargout = set(varargin)
        varargout = get(varargin)
        
        function value = get.position(obj)
            value = obj.internalPosition;
        end
        
        function value = getOriginalPosition(obj)
            value = obj.originalPosition;
        end
        
        function set.alignAxes(obj,value)
            if ~isnumeric(value) && ~isempty(value)
                error([mfilename ':: The alignAxes property must be set'...
                    ' to a scalar double.'])
            end
            obj.alignAxes = value;
        end
        
        function set.annotations(obj,value)
            if ~iscell(value)
                error([mfilename ':: The annotations property must be set'...
                    ' to a cell with annotation objects.'])
            end
            obj.annotations = value;
        end
        
        function set.axisVisible(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The axisVisible property must be'...
                    ' set to a ''on'' or ''off''.'])
            end
            obj.axisVisible = value;
        end
        
        function set.color(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The color property must be'...
                    ' set to either ''none'' or a valid'...
                    ' property value (RGB vector or a MATLAB'...
                    ' predefined name).'])
            end
            obj.color = value;
        end
        
        function set.colorMap(obj,value)
            err = true;
            if isempty(value)
                value = [];
                err   = false;
            elseif isa(value,'double')
                if nb_sizeEqual(value,[nan,3])
                    err = false;
                end
            elseif nb_isOneLineChar(value)
                err = false;
            end
            if err
                error([mfilename ':: The colormap property must be'...
                    ' set to a N x 3 double with the RGB colors or a one line',...
                    ' char with the file containing the color map.'])
            end
            obj.colorMap = value;
        end
        
        function set.dashType(obj,value)
            if ~any(ismember({'char(173)','char(8211)','char(8212)'},value))
                error([mfilename ':: The dashType property must be'...
                    ' set to either char(173) (dash),'...
                    ' char(8211) (en-dash) or char(8212)'
                    ' (em-dash).'])
            end
            obj.dashType = value;
        end
        
        function set.deleteOption(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The deleteOption property must be'...
                    ' set to a one line character array.'])
            end
            obj.deleteOption = value;
        end
        
        function set.findAxisLimitMethod(obj,value)
            if ~any(ismember([1,2,3,4],value))
                error([mfilename ':: The findAxisLimitMethod property must'...
                    ' be set to either 1, 2, 3 or 4.'])
            end
            obj.findAxisLimitMethod = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontName property must'...
                    ' be set to a one line character array.'])
            end
            obj.fontName = value;
        end
        
        function set.fontSize(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The fontSize property must be'...
                    ' set to a double.'])
            end
            obj.fontSize = value;
        end
        
        function set.fontSizeX(obj,value)
            if ~nb_isScalarNumber(value) && ~isempty(value)
                error([mfilename ':: The fontSizeX property must be'...
                    ' set to a double.'])
            end
            obj.fontSizeX = value;
        end
        
        function set.fontUnits(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'points',...
                    'normalized'...
                    'inches','centimeters','pixels'},value))
                error([mfilename ':: The fontUnits property must be'...
                    ' set to either ''points'', ''normalized'''...
                    ' ''inches'', ''centimeters'' or ''pixels''.'])
            end
            obj.fontUnits = value;
        end
        
        function set.fontWeight(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontWeight property must be'...
                    ' set to a one line character array.'])
            end
            obj.fontWeight = value;
        end
        
        function set.grid(obj,value)
            if ~any(ismember({'off','on'},value))
                error([mfilename ':: The grid property must be'...
                    ' set to either ''on'' or ''off''.'])
            end
            obj.grid = value;
        end
        
        function set.gridColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The color property must be'...
                    ' set to either ''none'' or a valid'...
                    ' property value (RGB vector or a MATLAB'...
                    ' predefined name).'])
            end
            obj.gridColor = value;
        end
        
        function set.gridLineStyle(obj,value)
            if ~nb_islineStyle(value)
                error([mfilename ':: The gridLineStyle property must be'...
                    ' set to a valid lineStyle property.'])
            end
            obj.gridLineStyle = value;
        end
        
        function set.highLighted(obj,value)
            if isempty(value)
                obj.highLighted = value;
                return
            end
            if ~iscell(value)
                error([mfilename ':: The highLighted property must be set'...
                    ' to a cell with all the highlighted '...
                    'area handles.'])
            end
            obj.highLighted = value;
        end
        
        function set.horizontalLine(obj,value)
            if isempty(value)
                obj.horizontalLine = value;
                return
            end
            if ~iscell(value)
                error([mfilename ':: The horizontalLine property must be'...
                    ' set to a cell with all the horizontal'...
                    ' area handles.'])
            end
            obj.horizontalLine = value;
        end
        
        function set.language(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The language property must be set to'...
                    ' either ''norsk'' or ''english'' (default).'])
            end
            obj.language = value;
        end
        
        function set.legend(obj,value)
            if ~isa(value,'nb_legend') && ~isempty(value)
                error([mfilename ':: The legend property must be set given'...
                    ' as an nb_legend object.'])
            end
            obj.legend = value;
        end

        function set.limMode(obj,value)
            if ~any(ismember({'manual','auto'},value)) && nb_isOneLineChar(value)
                error([mfilename ':: The limMode property must be set '...
                    'to either ''manual'' or ''auto'' (default).'])
            end
            obj.limMode = value;
        end
        
        function set.lineWidth(obj,value)
            if ~nb_isScalarNumber(value,0)
                error([mfilename ':: The lineWidth property must be set to '...
                    'a scalar number.'])
            end
            obj.lineWidth = value;
        end
        
        function set.normalized(obj,value)
            if ~any(ismember({'figure','axes'},value)) && nb_isOneLineChar(value)
                error([mfilename ':: The normalized property must be set to'...
                    ' either ''normalized'' or ''axes'' (default).'])
            end
            obj.normalized = value;
        end
        
        function set.parent(obj,value)
            if ~(isa(value,'nb_figure') || nb_isFigure(value) || nb_isPanel(value))
                error([mfilename ':: The parent property must be given'...
                    ' as a figure or nb_figure object.'])
            end
            obj.parent = value;
        end
        
        function set.plotBoxAspectRatio(obj,value)
            if ~all([1,3] == size(value))
                error([mfilename ':: The plotBoxAspectRatio property must'...
                    ' be given as a 1x3 double.'])
            end
            obj.plotBoxAspectRatio = value;
        end
        
        function set.position(obj,value)
            if ~nb_sizeEqual(value,[1,4])
                error([mfilename ':: The position property must'...
                    ' be given as a 1x4 double.'])
            end
            obj.originalPosition = value;
            obj.internalPosition = value;
        end
        
        function set.orientation(obj,value)
            if ~any(ismember({'vertical','horizontal'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The orientation property must be set'...
                    ' to either ''vertical'' or ''horizontal'' (default).'])
            end
            obj.orientation = value;
        end
        
        function set.scaleFactor(obj,value)
            if ~nb_isScalarNumber(value) && ~isempty(value)
                error([mfilename ':: The scaleFactor property must be'...
                    ' given as a scalar number.'])
            end
            obj.scaleFactor = value;
        end
        
        function set.scaleLineWidth(obj,value)
            if isnumeric(value)
                value = logical(value);
            end
            if ~nb_isScalarLogical(value)
                error([mfilename ':: The scaleLineWidth property must be'...
                    ' given as either true or false.'])
            end
            obj.scaleLineWidth = value;
        end
        
        function set.shading(obj,value)
            obj.shading = value;
        end
        
        function set.tickDir(obj,value)
            if ~any(ismember({'in','out','none'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The tickDir property must be set'...
                    ' to either ''out'' or ''in'' (default).'])
            end
            obj.tickDir = value;
        end
        
        function set.tickLength(obj,value)
            if ~all(ismember([1 2],size(value))) && ~isa(value,'double')
                error('The tickLength property must be given as a 1x2 double.')
            end
            obj.tickLength = value;
        end
        
        %         function set.title(obj,value)
        %             if ~isa(value,'nb_title')
        %                 error([mfilename ':: The title property must be given'...
        %                    ' as an nb_title handle.'])
        %             end
        %             obj.title = value;
        %         end
        
        %         function set.UIContextMenu(obj,value)
        %             if ~
        %                 error([mfilename ':: The UIContextMenu property must be .'])
        %             end
        %             obj.UIContextMenu = value;
        %         end
        
        function set.units(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The units property must be given as'...
                    ' a one line char.'])
            end
            obj.units = value;
        end
        
        function set.update(obj,value)
            if ~any(ismember({'off','on'},value)) && nb_isOneLineChar(value)
                error([mfilename ':: The update property must be set'...
                    ' to either ''off'' or ''on'' (default).'])
            end
            obj.update = value;
        end
        
        function set.verticalLine(obj,value)
            if isempty(value)
                obj.verticalLine = value;
                return
            end
            if ~isa(value,'cell') ||  ~isa(value{1},'nb_verticalLine')
                error([mfilename ':: The verticalLine property must be '...
                    'given as a cell array containing all the '...
                    'nb_verticalLine objects.'])
            end
            obj.verticalLine = value;
        end
        
        function set.visible(obj,value)
            if ~any(ismember({'off','on'},value)) && nb_isOneLineChar(value)
                error([mfilename ':: The visible property must be set'...
                    ' to either ''off'' or ''on'' (default).'])
            end
            obj.visible = value;
        end
        
        function set.xLabel(obj,value)
            if ~isa(value,'nb_xlabel')
                error([mfilename ':: The xLabel property must be given'...
                    ' as an nb_xlabel object.'])
            end
            obj.xLabel = value;
        end
        
        function set.xLim(obj,value)
            if ~all(ismember([1 2],size(value))) && ~isempty(value)
                error([mfilename ':: The xLim property must be given'...
                    ' as a 1x2 double.'])
            end
            obj.xLim = value;
        end
        
        
        function set.xOffset(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The xOffset property must be given'...
                    ' as a scalar double.'])
            end
            obj.xOffset = value;
        end
        
        function set.xScale(obj,value)
            if ~any(ismember({'log','linear'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The xScale property must be set'...
                    ' to either ''log'' or ''linear'' (default).'])
            end
            obj.xScale = value;
        end
        
        function set.xTick(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The xTick property must be given'...
                    ' as a double vector.'])
            end
            obj.xTick = value;
        end
        
        function set.xTickLabel(obj,value)
            if ~isa(value,'double') && ~isa(value,'cell') && ~isa(value,'char')
                error([mfilename ':: The xTickLabel property must be given'...
                    ' as a cellstring or a double vector.'])
            end
            obj.xTickLabel = value;
        end
        
        function set.xTickLabelLocation(obj,value)
            if ~any(ismember({'top','baseline','bottom'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The xTickLabelLocation property must'...
                    ' be set to either ''top'',''baseline'' or'...
                    ' ''bottom'' (default).'])
            end
            obj.xTickLabelLocation = value;
        end
        
        function set.xTickLabelAlignment(obj,value)
            if ~any(ismember({'normal','middle','below','start'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The xTickLabelAlignment property must'...
                    ' be set to either ''middle'' or ''normal'' (default).'])
            end
            obj.xTickLabelAlignment = value;
        end
        
        function set.xTickLocation(obj,value)
            if ~nb_isOneLineChar(value) && ~isa(value,'double')
                error([mfilename ':: The xTickLabelLocation property must'...
                    ' be set to either ''top'',''double'' or'...
                    ' ''bottom'' (default).'])
            end
            obj.xTickLocation = value;
        end
        
        function set.xTickRotation (obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The xTickRotation property must '...
                    ' be given as a scalar double.'])
            end
            obj.xTickRotation  = value;
        end
        
        function set.xTickVisible(obj,value)
            if ~any(ismember([0 1],value))
                error([mfilename ':: The xTickVisible property must be '...
                    'set to either 0 or 1.'])
            end
            obj.xTickVisible = value;
        end
        
        function set.yDir(obj,value)
            if ~any(ismember({'normal','reverse'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The yDir property must '...
                    'be set to either ''reverse'' or ''normal'' (default).'])
            end
            obj.yDir = value;
        end
        
        function set.yDirRight(obj,value)
            if ~any(ismember({'normal','reverse'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The yDirRight property must '...
                    'be set to either ''reverse'' or ''normal'' (default).'])
            end
            obj.yDirRight = value;
        end
        
        function set.yLabel(obj,value)
            if ~isa(value,'nb_ylabel') && ~isempty(value)
                error([mfilename ':: The yLabel property must be given'...
                    ' as an nb_ylabel object.'])
            end
            obj.yLabel = value;
        end
        
        function set.yLabelRight(obj,value)
            if ~isa(value,'nb_ylabel') && ~isempty(value)
                error([mfilename ':: The yLabelRight property must be '...
                    'given as an nb_ylabel object.'])
            end
            obj.yLabelRight = value;
        end
        
        function set.yLim(obj,value)
            if ~all(ismember([1 2],size(value))) && ~isa(value,'double')
                error([mfilename ':: The yLim property must be given'...
                    ' as a 1x2 double.'])
            end
            obj.yLim = value;
        end
        
        function set.yLimRight(obj,value)
            if ~all(ismember([1 2],size(value))) && ~isa(value,'double')
                error([mfilename ':: The yLimRight property must be given'...
                    ' as a 1x2 double.'])
            end
            obj.yLimRight = value;
        end
        
        function set.yOffset(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The yOffset property must be given'...
                    ' as a scalar double.'])
            end
            obj.yOffset = value;
        end
        
        function set.yScale(obj,value)
            if ~any(ismember({'log','linear'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The yScale property must be set'...
                    ' to either ''log'' or ''linear'' (default).'])
            end
            obj.yScale = value;
        end
        
        
        function set.yScaleRight(obj,value)
            if ~any(ismember({'log','linear'},value)) && ...
                    nb_isOneLineChar(value)
                error([mfilename ':: The yScaleRight property must be set'...
                    ' to either ''log'' or ''linear'' (default).'])
            end
            obj.yScaleRight = value;
        end
        
        function set.yTick(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yTick property must be given'...
                    ' as a double vector.'])
            end
            obj.yTick = value;
        end
        
        function set.yTickRight(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yTickRight property must be given'...
                    ' as a double vector.'])
            end
            obj.yTickRight = value;
        end
        
        function set.yTickLabel(obj,value)
            if ~isa(value,'double') && ~isa(value,'cell')  && ~isa(value,'char')
                error([mfilename ':: The yTickLabel property must be given'...
                    ' as a cellstring or a double vector.'])
            end
            obj.yTickLabel = value;
        end
        
        function set.yTickLabelRight(obj,value)
            if ~isa(value,'double') && ~isa(value,'cell') && ~isa(value,'char')
                error([mfilename ':: The yTickLabelRight property must be'...
                    'given as a cellstring or a double vector.'])
            end
            obj.yTickLabelRight = value;
        end
        
        function set.yTickVisible(obj,value)
            if ~any(ismember([0 1],value))
                error([mfilename ':: The yTickVisible property must be '...
                    'set to either 0 or 1.'])
            end
            obj.yTickVisible = value;
        end
        
        function value = getColorMap(obj)
            
            value = obj.colorMap;
            if isempty(value)
                value = nb_axes.defaultColorMap();
            else
                if ischar(obj.colorMap)
                    try
                        value = nb_load(value);
                    catch Err
                        try
                            cMapFunc = str2func(obj.colorMap);
                            value    = cMapFunc();
                        catch
                            rethrow(Err)
                        end    
                    end
                end
            end
            
        end
        
        %{
        ---------------------------------------------------------------
        Delete the object, but not the MATLAB axes handles
        ---------------------------------------------------------------
        %}
        function delete(obj)
            
            % Remove it from the parent if the parent is an nb_figure
            % object
            if isa(obj.parent,'nb_figure')
                if isvalid(obj.parent)
                    try obj.parent.removeAxes(obj); catch; end %#ok<CTCH>
                end
            end
            
            % Delete all the children handles of the object
            for ii = 1:size(obj.children,2)
                
                try
                    if isvalid(obj.children{ii})
                        % Set the delete option for the children
                        obj.children{ii}.deleteOption = obj.deleteOption;
                        delete(obj.children{ii})
                    end
                catch
                end
                
            end
            
            for ii = 1:size(obj.annotations,2)
                
                if isvalid(obj.annotations{ii})
                    
                    % Set the delete option for the children
                    if strcmpi(obj.deleteOption,'all')
                        childs = obj.annotations{ii}.children;
                        if iscell(childs)
                            for jj = 1:length(childs)
                                delete(childs{jj});
                            end
                        else
                            delete(childs);
                        end
                    end
                    set(obj.annotations{ii},'parent',[]);
                    
                end
                
            end
            
            for ii = 1:size(obj.highLighted,2)
                if isvalid(obj.highLighted{ii}) 
                    % Set the delete option for the children
                    obj.highLighted{ii}.deleteOption = obj.deleteOption;
                    delete(obj.highLighted{ii})
                end
            end
            
            for ii = 1:size(obj.horizontalLine,2)
                if isvalid(obj.horizontalLine{ii})
                    % Set the delete option for the children
                    obj.horizontalLine{ii}.deleteOption = obj.deleteOption;
                    delete(obj.horizontalLine{ii})
                end            
            end
            
            for ii = 1:size(obj.verticalLine,2)
                if isvalid(obj.verticalLine{ii})                
                    % Set the delete option for the children
                    obj.verticalLine{ii}.deleteOption = obj.deleteOption;
                    delete(obj.verticalLine{ii})
                end
            end
            
            if ~isempty(obj.legend)
                if isvalid(obj.legend)
                    obj.legend.deleteOption = obj.deleteOption;
                    delete(obj.legend)
                end
            end
            
            if ~isempty(obj.yLabel)
                if isvalid(obj.yLabel)
                    obj.yLabel.deleteOption = obj.deleteOption;
                    delete(obj.yLabel)
                end
            end
            
            if ~isempty(obj.yLabelRight)
                if isvalid(obj.yLabelRight)
                    obj.yLabelRight.deleteOption = obj.deleteOption;
                    delete(obj.yLabelRight)
                end
            end
            
            if ~isempty(obj.xLabel)
                if isvalid(obj.xLabel)
                    obj.xLabel.deleteOption = obj.deleteOption;
                    delete(obj.xLabel)
                end
            end
            
            if ~isempty(obj.title)
                if isvalid(obj.title)
                    obj.title.deleteOption = obj.deleteOption;
                    delete(obj.title)
                end
            end
            
            if strcmpi(obj.deleteOption,'all')
                
                % Delete all the tick mark objects
                for ii = 1:size(obj.tickObjects,2)
                    if ishandle(obj.tickObjects(ii))
                        delete(obj.tickObjects(ii))
                    end
                end
                
                % Delete also th plotted axes (The MATLAB axes objects)
                if ishandle(obj.axesHandle)
                    delete(obj.axesHandle);
                end
                if ishandle(obj.axesHandleRight)
                    delete(obj.axesHandleRight);
                end
                if ishandle(obj.axesLabelHandle)
                    delete(obj.axesLabelHandle);
                end
                if ishandle(obj.plotAxesHandle)
                    delete(obj.plotAxesHandle);
                end
                if ishandle(obj.plotAxesHandleRight)
                    delete(obj.plotAxesHandleRight);
                end
                if ishandle(obj.shadingAxes)
                    delete(obj.shadingAxes);
                end
                
            end
            
            if ~isempty(obj.listeners)
                if isvalid(obj.listeners)
                    delete(obj.listeners)
                end
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add a child
        -------------------------------------------------------------------
        %}
        function addChild(obj,child)
            
            if isa(child,'nb_plotHandle')
                
                if isa(child,'nb_horizontalLine')
                    
                    found = 0;
                    for ii = 1:size(obj.horizontalLine,2)
                        found = obj.horizontalLine{ii} == child;
                        if found
                            break;
                        end
                    end
                    if ~found
                        obj.horizontalLine = [obj.horizontalLine, {child}];
                    end
                    
                elseif isa(child,'nb_verticalLine')
                    
                    found = 0;
                    for ii = 1:size(obj.verticalLine,2)
                        found = obj.verticalLine{ii} == child;
                        if found
                            break;
                        end
                    end
                    if ~found
                        obj.verticalLine = [obj.verticalLine, {child}];
                    end
                    
                elseif isa(child,'nb_image')
                    
                    % Can only add one image at once
                    obj.imageChild = child;
                    
                else
                    
                    found = 0;
                    for ii = 1:size(obj.children,2)
                        found = obj.children{ii} == child;
                        if found
                            break;
                        end
                    end
                    if ~found
                        obj.children = [obj.children, {child}];
                    end
                    
                end
                
            else
                error([mfilename ':: It is only possible to add an object which is a subclass of the nb_plotHandle '...
                    'class to an object of class nb_axes'])
            end
            
            % Graph the axes again given the new child. (Changes to limits
            % can happend)
            %--------------------------------------------------------------
            graphAxes(obj);
            
        end
        
        %{
        -------------------------------------------------------------------
        Add a annotation
        -------------------------------------------------------------------
        %}
        function addAnnotation(obj,ann)
            
            if isa(ann,'nb_annotation')
                
                found = 0;
                for ii = 1:size(obj.annotations,2)
                    found = obj.annotations{ii} == ann;
                    if found
                        break;
                    end
                end
                if ~found
                    obj.annotations = [obj.annotations, {ann}];
                end
                
            else
                error([mfilename ':: It is only possible to add an object which is a subclass of the nb_annotation '...
                    'class to an object of class nb_axes'])
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add a highlighted area handle
        -------------------------------------------------------------------
        %}
        function addHighlighted(obj,highLightedHandle)
            
            if isa(highLightedHandle,'nb_highlight')
                
                found = 0;
                for ii = 1:size(obj.highLighted,2)
                    found = obj.highLighted{ii} == highLightedHandle;
                    if found
                        break;
                    end
                end
                if ~found
                    obj.highLighted = [obj.highLighted, {highLightedHandle}];
                end
                
            end
            
            % Graph the axes again given the new child. (Changes to limits
            % can happend)
            graphAxes(obj);
            
        end
        
        %{
        -------------------------------------------------------------------
        Add a legend
        -------------------------------------------------------------------
        %}
        function addLegend(obj,legendObj)
            
            if isa(legendObj,'nb_legend')
                obj.legend = legendObj;
            end
            
            % Plot the legend
            obj.updateLegend();
            
        end
        
        %{
        -------------------------------------------------------------------
        Add a title
        -------------------------------------------------------------------
        %}
        function addTitle(obj,child)
            
            if isa(child,'nb_title')
                obj.title = child;
            else
                error([mfilename ':: The input must be an object of class nb_title'])
            end
            
            % Plot the title
            %--------------------------------------------------------------
            obj.title.update();
            
        end
        
        %{
        -------------------------------------------------------------------
        Add a x-axis label
        -------------------------------------------------------------------
        %}
        function addXLabel(obj,child)
            
            if isa(child,'nb_xlabel')
                obj.xLabel = child;
            else
                error([mfilename ':: The input must be an object of class nb_xlabel'])
            end
            
            % Plot the x-axis label
            %--------------------------------------------------------------
            obj.xLabel.update();
            
        end
        
        %{
        -------------------------------------------------------------------
        Add a x-axis label
        -------------------------------------------------------------------
        %}
        function addYLabel(obj,child)
            
            if isa(child,'nb_ylabel')
                if strcmpi(child.side,'right')
                    obj.yLabelRight = child;
                    obj.yLabelRight.update();
                else
                    obj.yLabel = child;
                    obj.yLabel.update();
                end
            else
                error([mfilename ':: The input must be an object of class nb_ylabel'])
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove a child
        -------------------------------------------------------------------
        %}
        function removeChild(obj,child)
            
            if isa(child,'nb_plotHandle')
                
                if isa(child,'nb_horizontalLine')
                    looped = obj.horizontalLine;
                elseif isa(child,'nb_verticalLine')
                    looped = obj.verticalLine;
                else
                    looped = obj.children;
                end
                found = 0;
                
                % Look for the children which match
                for ii = 1:size(looped,2)
                    found = looped{ii} == child;
                    if found
                        break;
                    end
                end
                
                if found
                    
                    % Remove the found object
                    looped = [looped(1:ii - 1), looped(ii + 1:end)];
                    if isa(child,'nb_horizontalLine')
                        obj.horizontalLine = looped;
                    elseif isa(child,'nb_verticalLine')
                        obj.verticalLine = looped;
                    else
                        obj.children = looped;
                    end
                    
                end
                
                % Update the axes
                if isvalid(obj)
                    graphAxes(obj);
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove a annotation
        -------------------------------------------------------------------
        %}
        function removeAnnotation(obj,ann)
            
            if isa(ann,'nb_annotation')
                
                looped = obj.annotations;
                found  = 0;
                
                % Look for the children which match
                for ii = 1:size(looped,2)
                    
                    found = looped{ii} == ann;
                    if found
                        break;
                    end
                    
                end
                
                if found
                    
                    % Remove the found object
                    looped          = [looped(1:ii - 1), looped(ii + 1:end)];
                    obj.annotations = looped;
                    
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove highlighted area from the current object
        -------------------------------------------------------------------
        %}
        function removeHighlighted(obj,toBeRemoved)
            
            found  = 0;
            looped = obj.highLighted;
            
            % Look for the children which match
            for ii = 1:size(looped,2)
                found = looped{ii} == toBeRemoved;
                if found
                    break;
                end
            end
            
            if found
                % Remove the found object
                obj.highLighted = [looped(1:ii - 1), looped(ii + 1:end)];
            else
                warning([mfilename ':: Did not found the given handle in the given nb_axes handle (object).'])
            end
            
            % Update the axes
            graphAxes(obj);
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove title from the current object
        -------------------------------------------------------------------
        %}
        function removeTitle(obj,titleToBeRemoved)
            
            if obj.title == titleToBeRemoved
                obj.title = [];
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove xLabel from the current object
        -------------------------------------------------------------------
        %}
        function removeXLabel(obj,xLabelToBeRemoved)
            
            if obj.xLabel == xLabelToBeRemoved
                obj.xLabel = [];
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove yLabel from the current object
        -------------------------------------------------------------------
        %}
        function removeYLabel(obj,yLabelToBeRemoved)
            
            if obj.yLabel == yLabelToBeRemoved
                obj.yLabel = [];
            elseif obj.yLabelRight == yLabelToBeRemoved
                obj.yLabelRight = [];
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove a legend
        -------------------------------------------------------------------
        %}
        function removeLegend(obj,legendToBeRemoved)
            
            if obj.legend == legendToBeRemoved
                obj.legend = [];
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the lowest point. In normalized units.
        
        force is used when the nb_xlabel class is calculating where
        it should locate itself.
        -------------------------------------------------------------------
        %}
        function lowest = getYLow(obj,force)
            
            if nargin == 1
                force = 0;
            end
            
            if isempty(obj.xLabel) || force == 1
                
                pos = obj.position;
                if strcmpi(obj.xTickLabelLocation,'bottom')
                    
                    lowest = pos(2) - obj.xOffset*pos(4);
                    ext    = 0;
                    for ii = 1:length(obj.xTickLabelObjects)
                        if ishandle(obj.xTickLabelObjects(ii))
                            extent = get(obj.xTickLabelObjects(ii),'extent');
                        else
                            extent = zeros(1,4);
                        end
                        if extent(4) > ext
                            ext = extent(4);
                        end
                    end
                    lowest = lowest - ext - 0.006;
                    
                else
                    
                    lowest = pos(2);
                    if isempty(obj.yTickLabelObjects)
                        ext = zeros(1,4);
                    else
                        ext = get(obj.yTickLabelObjects(1),'extent');
                    end
                    lowest = lowest - ext(4)/2;
                    
                end
                
            else
                lowest = obj.xLabel.extent(2) - 0.006;
            end
            
            if force == 0
                
                % If we are not getting the coordinates for the
                % xLabel we must also secure that the we take the
                % legend into account. (It could be placed below
                % the axes)
                if ~isempty(obj.legend)
                    
                    if ~isempty(obj.legend.legends)
                        
                        lowestLeg = obj.legend.extent(2);
                        
                        if lowestLeg < lowest + 0.006
                            lowest = lowestLeg - 0.006;
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the highest point. In normalized units
        -------------------------------------------------------------------
        %}
        function highest = getYHigh(obj)
            
            if strcmpi(obj.xTickLabelLocation,'top')
                
                pos     = obj.position;
                highest = pos(2) + pos(4) + obj.xOffset*pos(4);
                ext     = 0;
                
                for ii = 1:length(obj.xTickLabelObjects)
                    if  ishandle(obj.xTickLabelObjects(ii))
                        extent = get(obj.xTickLabelObjects(ii),'extent');
                    else
                        extent = zeros(1,4);
                    end
                    if extent(4) > ext
                        ext = extent(4);
                    end
                end
                highest = highest + ext + 0.006;
                
            else
                
                pos     = obj.position;
                highest = pos(2) + pos(4);
                if isempty(obj.yTickLabelObjects)
                    extent = zeros(1,4);
                else
                    if ishandle(obj.yTickLabelObjects(1))
                        extent = get(obj.yTickLabelObjects(1),'extent');
                    else
                        extent = zeros(1,4);
                    end
                end
                highest = highest + extent(4)/2 + 0.006;
                
            end
            
            % If the axes has a title we must correct for that
            if ~isempty(obj.title)
                
                % Get the MATLAB title handle
                tit = obj.title.children;
                
                % Get the extent of the MATLAB title
                ext = nb_getInUnits(tit,'extent','normalized');
                
                % Normalize the units to the figure
                pos = obj.position;
                ext = ext(4)*pos(4);
                
                % Add the high of the title text to the highest
                % otherwise found value
                highest = highest + ext;
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the left most point. In normalized units
        
        force is used when the nb_ylabel class is calculating where
        it should locate itself.
        -------------------------------------------------------------------
        %}
        function leftMost = getLeftMost(obj,force)
            
            if nargin == 1
                force = 0;
            end
            
            if isempty(obj.yLabel) || force
                
                % The x-axis location
                pos = obj.position;
                tH  = obj.yTickLabelObjects;
                ext = 0;
                if all(ishandle(tH)) 
                    for ii = 1:size(tH,2) 
                        extent = get(tH(ii),'extent');
                        if extent(3) > ext
                            ext = extent(3);
                        end  
                    end
                elseif ~isempty(obj.xTickLabelObjects) && ishandle(obj.xTickLabelObjects(1))
                    extent = get(obj.xTickLabelObjects(1),'extent');
                    ext    = extent(3);
                end
                leftMost = pos(1) - ext - obj.yOffset*pos(3);
                
            else
                extent   = obj.yLabel.extent;
                leftMost = extent(1) - extent(3);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the right most point. In normalized units
        
        force is used when the nb_ylabel class is calculating where
        it should locate itself.
        -------------------------------------------------------------------
        %}
        function rightMost = getRightMost(obj,force)
            
            if nargin == 1
                force = 0;
            end
            
            useLegend = false;
            if ~isempty(obj.legend)
                if any(strcmpi(obj.legend.location,{'outsideright','outsiderighttop'}))
                    useLegend = true;
                end
            end
            if useLegend
                extent = obj.legend.extent;
                if ~isempty(extent)
                    rightMost = extent(1) + extent(3);
                    return
                end
            end
            if isempty(obj.yLabelRight) || force == 1
                pos       = obj.position;
                ext       = getRightLabelsExtent(obj);
                rightMost = pos(1) + pos(3) + ext + obj.yOffset*pos(3);
            else
                extent    = obj.yLabelRight.extent;
                rightMost = extent(1) + extent(3);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the right most point. Used by nb_legend
        -------------------------------------------------------------------
        %}
        function rightMost = getRightMostOriginal(obj)
            
            pos = obj.position;
            if isempty(obj.yLabelRight) 
                ext       = getRightLabelsExtent(obj);
                rightMost = pos(1) + pos(3) + ext + obj.yOffset*pos(3);
            else
                extent    = obj.yLabelRight.extent;
                rightMost = extent(1) + extent(3);
            end
            rightMost = rightMost + (obj.originalPosition(3) - pos(3));
            
        end
        
        function ext = getRightLabelsExtent(obj)
            
            tH  = obj.yTickLabelRightObjects;
            ext = 0;
            if all(ishandle(tH))  
                for ii = 1:size(tH,2)                        
                    extent = get(tH(ii),'extent');
                    if extent(3) > ext
                        ext = extent(3);
                    end                 
                end
            end
            ext = ext*(obj.position(3)/obj.originalPosition(3));
            
        end
        
        %{
        -------------------------------------------------------------------
        Find y-axis limits of the children of the left axes
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimitsLeft(obj)
            
            % Set the default if there are no children on the left axes
            ylimit = [0, 1];
            
            % Then loop through the children to find the lowest and highest
            % y-axis limits
            first  = 1;
            for ii = 1:size(obj.children,2)
                
                child = obj.children{ii};
                if strcmpi(get(child,'side'),'left')
                    
                    if first == 1
                        
                        ylimit = child.findYLimits();
                        first  = 0;
                        
                    else
                        
                        ylimitTemp = child.findYLimits();
                        if ylimit(1) > ylimitTemp(1)
                            ylimit(1) = ylimitTemp(1);
                        end
                        
                        if ylimit(2) < ylimitTemp(2)
                            ylimit(2) = ylimitTemp(2);
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Find y-axis limits of the children of the right axes
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimitsRight(obj)
            
            % Set the default if there are no children on the right axes
            ylimit = [];
            
            % Then loop through the children to find the lowest and highest
            % y-axis limits
            first  = 1;
            for ii = 1:size(obj.children,2)
                
                child = obj.children{ii};
                if strcmpi(get(child,'side'),'right')
                    
                    if first == 1
                        
                        ylimit = child.findYLimits();
                        first  = 0;
                        
                    else
                        
                        ylimitTemp = child.findYLimits();
                        
                        if ylimit(1) > ylimitTemp(1)
                            ylimit(1) = ylimitTemp(1);
                        end
                        
                        if ylimit(2) < ylimitTemp(2)
                            ylimit(2) = ylimitTemp(2);
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Find x-axis limits of the children of the axes
        -------------------------------------------------------------------
        %}
        function xlimit = findXLimits(obj)
            
            % Set the default if there are no children off the axes
            xlimit = [0, 1];
            
            % Then loop through the children to find the lowest and highest
            % y-axis limits
            first  = 1;
            for ii = 1:size(obj.children,2)
                
                child = obj.children{ii};
                
                if first == 1
                    
                    xlimit = child.findXLimits();
                    first  = 0;
                    
                else
                    
                    xlimitTemp = child.findXLimits();
                    
                    if xlimit(1) > xlimitTemp(1)
                        xlimit(1) = xlimitTemp(1);
                    end
                    
                    if xlimit(2) < xlimitTemp(2)
                        xlimit(2) = xlimitTemp(2);
                    end
                    
                end
                
                
            end
            
            if diff(xlimit) == 0
                xlimit = xlimit + [-1 1];
            end
            if isnan(xlimit(1))
                xlimit(1) = 0;
            end
            if isnan(xlimit(2))
                xlimit(2) = 1;
            end
            
        end
        
        function notifyMouseOverObject(obj,fig,~)
            
            axr = obj.plotAxesHandleRight;
            axl = obj.plotAxesHandle;
            if ~ishandle(axr) || ~ishandle(axr)
                % The axes are deleted
                return
            end
            
            % Find current point in data units
            pos        = get(obj,'position');
            cPoint     = nb_getCurrentPointInAxesUnits(fig,obj);
            cPointL(1) = nb_pos2pos(cPoint(1),[pos(1),pos(1) + pos(3)],get(axl,'xLim'),'normal',get(axl,'xScale'));
            cPointL(2) = nb_pos2pos(cPoint(2),[pos(2),pos(2) + pos(4)],get(axl,'yLim'),'normal',get(axl,'yScale'));
            cPointR(1) = nb_pos2pos(cPoint(1),[pos(1),pos(1) + pos(3)],get(axr,'xLim'),'normal',get(axr,'xScale'));
            cPointR(2) = nb_pos2pos(cPoint(2),[pos(2),pos(2) + pos(4)],get(axr,'yLim'),'normal',get(axr,'yScale'));
            
            % Loop children
            for ii = length(obj.children):-1:1
                
                child = obj.children{ii};
                if isa(child,'nb_plotHandle') && isa(child,'nb_notifiesMouseOverObject')
                    
                    try
                        side = child.side;
                    catch %#ok<CTCH>
                        side = 'left';
                    end
                    if strcmpi(side,'right')
                        [x,y,value] = notifyMouseOverObject(child,cPointR);
                        cPointOut    = cPointR;
                    else
                        [x,y,value] = notifyMouseOverObject(child,cPointL);
                        cPointOut    = cPointL;
                    end
                    
                    if ~isempty(value)
                        
                        if strcmpi(side,'right')
                            axPlot = axr;
                        else
                            axPlot = axl;
                        end
                        
                        % We need to plot the text box in this axes as this is on the top.
                        % As such we need to convert to this axes data units
                        ax           = obj.axesLabelHandle;
                        cPointOut(1) = nb_pos2pos(cPointOut(1),get(axPlot,'xLim'),get(ax,'xLim'),get(axPlot,'xScale'),get(ax,'xScale'));
                        cPointOut(2) = nb_pos2pos(cPointOut(2),get(axPlot,'yLim'),get(ax,'yLim'),get(axPlot,'yScale'),get(ax,'yScale'));
                        
                        notify(obj,'mouseOverObject',nb_mouseOverObjectEvent(x,y,ii,value,cPointOut));
                        return
                        
                    end
                    
                end
                
            end
            
            % If we get here no children has notified the axes, so we
            % notify that
            notify(obj,'mouseOverObject',nb_mouseOverObjectEvent([],[],[],[],cPoint));
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the axes given some setted settings
        -------------------------------------------------------------------
        %}
        function updateAxes(obj)
            
            graphAxes(obj);
            
        end
        
    end
    
    methods (Hidden=true)
        
        function updateLegend(obj)
            
            if isempty(obj.children)
                obj.removeLegend(obj.legend)
            else
                obj.legend.update();
            end
            adjustAxesGivenLegend(obj);
            
        end
        
        function adjustAxesGivenLegend(obj)
            
            if isempty(obj.legend)
                return
            end
            
            if any(strcmpi(obj.legend.location,{'outsideright','outsiderighttop'}))
                legExt                  = obj.legend.extent(1);
                ext                     = getRightLabelsExtent(obj);
                ext                     = ext + obj.yOffset*obj.originalPosition(3);
                obj.internalPosition    = obj.originalPosition;
                obj.internalPosition(3) = max(0.01,legExt(1) - obj.internalPosition(1) - ext);
                set(obj.axesHandle,'position',obj.internalPosition);
                set(obj.axesHandleRight,'position',obj.internalPosition);
                set(obj.axesLabelHandle,'position',obj.internalPosition);
                set(obj.plotAxesHandle,'position',obj.internalPosition);
                set(obj.plotAxesHandleRight,'position',obj.internalPosition);
                set(obj.shadingAxes,'position',obj.internalPosition);
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods of the class
    %======================================================================
    methods (Access=protected)
         
        function graphAxesFast(obj)
        
            if hasRightAxesChildren(obj)
                error([mfilename ':: You cannot use fast if you have plotted anything against the right axes.'])
            end
            
            % Make a figure parent if no parent exist
            if isempty(obj.parent)
                obj.parent = nb_figure('visible',obj.visible);
            end
            
            % Add this nb_axes handle to the parent handle if it is a
            % nb_figure handle
            if isa(obj.parent,'nb_figure')
                obj.parent.addAxes(obj);
                if isa(obj.parent,'nb_graphPanel')
                    par = obj.parent.panelHandle;
                else
                    par = obj.parent.figureHandle;
                end
            else
                par = obj.parent;
            end
            
            % Plot axes
            if ~isempty(obj.UIContextMenu)
                parUI = par;
                if strcmp(get(parUI,'type'),'uipanel')
                    parUI = get(parUI,'parent');
                end
                if parUI ~= get(obj.UIContextMenu,'parent')
                     set(obj.UIContextMenu,'parent',parUI);
                end
            end
            if strcmpi(obj.fontUnits,'normalized')
                pos = get(obj.plotAxesHandle,'position');
                if ~strcmpi(obj.normalized,'axes')
                    fontS = obj.fontSize*0.8/pos(4);
                else
                    fontS = obj.fontSize;
                end
                fontU = obj.fontUnits;
            else
                fontU = obj.fontUnits;
                fontS = obj.fontSize;
            end
            
            if ~isvalid(obj)
                return
            end
            if isempty(obj.plotAxesHandle)
                obj.plotAxesHandle = axes(...
                    'parent',       par,...
                    'box',          'on');
            elseif ~ishandle(obj.plotAxesHandle)
                obj.plotAxesHandle = axes(...
                    'parent',       par,...
                    'box',          'on');
            end
            if ~isempty(obj.UIContextMenu)
                parUI = par;
                if strcmp(get(parUI,'type'),'uipanel')
                    parUI = get(parUI,'parent');
                end
                if parUI ~= get(obj.UIContextMenu,'parent')
                     set(obj.UIContextMenu,'parent',parUI);
                end
            end
            set(obj.plotAxesHandle,...
                'color',        obj.color,...
                'units',        obj.units,...
                'position',     obj.position,...
                'visible',      obj.visible,...
                'tickDir',      obj.tickDir,...
                'fontWeight',   obj.fontWeight,...
                'fontName',     obj.fontName,...
                'fontUnits',    fontU,...
                'fontSize',     fontS,...
                'lineWidth',    obj.lineWidth,...
                'yDir',         obj.yDir,...
                'xScale',       obj.xScale,...
                'yScale',       obj.yScale,...
                'gridLineStyle',obj.gridLineStyle,...
                'gridColor',    obj.gridColor,...
                'UIContextMenu',obj.UIContextMenu,...
                'xGrid',        obj.grid,...
                'yGrid',        obj.grid);
            
            if obj.xLimSet
                set(obj.plotAxesHandle,'xLim',obj.xLim);
            else
                obj.xLim = get(obj.plotAxesHandle,'xLim');
            end
            if obj.yLimSet
                set(obj.plotAxesHandle,'yLim',obj.yLim);
            else
                obj.yLim = get(obj.plotAxesHandle,'yLim');
            end
            
            if ~isempty(obj.plotBoxAspectRatio)
                set(obj.plotAxesHandle,'plotBoxAspectRatio',obj.plotBoxAspectRatio);
            end
            
            % Update the object stored in the 'horizontalLine',
            % 'verticalLine' and 'highlighted' properties
            for ii = 1:size(obj.horizontalLine,2)
                obj.horizontalLine{ii}.update();
            end
            
            for ii = 1:size(obj.verticalLine,2)
                obj.verticalLine{ii}.update();
            end
            
            for ii = 1:size(obj.highLighted,2)
                obj.highLighted{ii}.update();
            end
            
            % Tick and labels
            % Set the 'xTick' and the 'xTickLabel' properties of the 
            % axes if given, or else the default is used
            %----------------------------------------------------------
            if obj.xTickSet
                set(obj.plotAxesHandle,'xTick',obj.xTick);
            else
                obj.xTick = get(obj.plotAxesHandle,'xTick');
            end

            if ~obj.xTickVisible
                set(obj.plotAxesHandle,'xTick',[]);
            end

            if obj.xTickLabelSet
                set(obj.plotAxesHandle,'xTickLabel',obj.xTickLabel);
            else
                obj.xTickLabel = get(obj.plotAxesHandle,'xTickLabel');
            end

            %----------------------------------------------------------
            % Set the 'yTick' and the 'yTickLabel' properties of the 
            % left axes if given, or else the default is used
            %----------------------------------------------------------
            if obj.yTickSet
                set(obj.plotAxesHandle,'yTick',obj.yTick);
            else
                obj.yTick = get(obj.plotAxesHandle,'yTick');
            end

            if ~obj.yTickVisible
                set(obj.axesHandle,'yTick',[]);
            end

            if obj.yTickLabelSet
                set(obj.plotAxesHandle,'yTickLabel',obj.yTickLabel);
            else
                obj.yTickLabel = get(obj.plotAxesHandle,'yTickLabel');
            end
            
            % Update the legend if it is not empty 
            if ~isempty(obj.legend)
                if isempty(obj.children)
                    obj.removeLegend(obj.legend)
                else
                    obj.legend.update();
                end
            end
            
            % Update the labels and titles
            if ~isempty(obj.xLabel)
                obj.xLabel.update();
            end
            if ~isempty(obj.yLabel)
                obj.yLabel.update();
            end
            if ~isempty(obj.yLabelRight)
                obj.yLabelRight.update();
            end
            if ~isempty(obj.title)
                obj.title.update();
            end

            % Update the annotations if it is not empty 
            for ii = 1:size(obj.annotations,2)
                obj.annotations{ii}.update();
            end
            
        end
        
        function graphAxes(obj)
            
            if ~isvalid(obj)
                return
            end
            
            %--------------------------------------------------------------
            % Don't do anything if the 'update' property is set to 'off'
            %--------------------------------------------------------------
            if strcmpi(obj.update,'off')
                return
            end
            
            if obj.fast
                graphAxesFast(obj)
                return 
            end
            
            % If the parent figure is deleted we don't do anything!
            if isa(obj.parent,'nb_figure')
                if ~ishandle(obj.parent.figureHandle)
                    return
                end
            else
                if ~ishandle(obj.parent)
                    return
                end
            end
            
            %--------------------------------------------------------------
            % Delete the axes where the axis is plotted on
            %--------------------------------------------------------------
            if ~isempty(obj.axesHandle)
                try
                    delete(obj.axesHandle)
                catch  %#ok<CTCH>
                    return
                end
            end
            
            if ~isempty(obj.axesHandleRight)
                delete(obj.axesHandleRight)
            end
            
            if ~isempty(obj.axesLabelHandle)
                delete(obj.axesLabelHandle)
            end
            
            if ~isempty(obj.tickObjects)
                for ii = 1:size(obj.tickObjects,2)
                    if ishandle(obj.tickObjects(ii))
                        delete(obj.tickObjects(ii));
                    end
                end
            end
            
            if ~isempty(obj.listeners)
                if isvalid(obj.listeners)
                    delete(obj.listeners)
                end
            end
            
            %--------------------------------------------------------------
            % Make a figure parent if no parent exist
            %--------------------------------------------------------------
            if isempty(obj.parent)
                obj.parent = nb_figure('visible',obj.visible);
            end
            
            %--------------------------------------------------------------
            % Add this nb_axes handle to the parent handle if it is a
            % nb_figure handle
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_figure')
                obj.parent.addAxes(obj);
                if isa(obj.parent,'nb_graphPanel')
                    par = obj.parent.panelHandle;
                else
                    par = obj.parent.figureHandle;
                end
            else
                par = obj.parent;
            end
            
            %--------------------------------------------------------------
            % Add the shaded background if wanted (In its on axes) Given by
            % 'shadingAxes' property. (Which is yet another axes handle)
            %--------------------------------------------------------------
            addShading(obj)
            
            %--------------------------------------------------------------
            % Initialize the axes to do the plotting on if it is empty.
            % Both the left axes to plot on and the right axes to plot on.
            %--------------------------------------------------------------
            if isempty(obj.plotAxesHandle)
                obj.plotAxesHandle      = axes('parent',par,'color','none');
                obj.plotAxesHandleRight = axes('parent',par,'color','none');
            end
            
            %--------------------------------------------------------------
            % Set the properties of the plot axes handle, given the
            % properties of this object
            %--------------------------------------------------------------
            if ~hasRightAxesChildren(obj)
                obj.yDirRight = obj.yDir;
            end
            
            set(obj.plotAxesHandle,'units',obj.units);
            set(obj.plotAxesHandle,'position',obj.position,'visible',obj.visible,'yDir',obj.yDir,...
                                   'xScale',obj.xScale,'yScale',obj.yScale);
                      
            if ~hasRightAxesChildren(obj)
                obj.yScaleRight = obj.yScale;
            end   
            set(obj.plotAxesHandleRight,'units',obj.units);
            set(obj.plotAxesHandleRight,'units',obj.units,'position',obj.position,'visible',obj.visible,'yDir',obj.yDirRight,...
                                        'xScale',obj.xScale,'yScale',obj.yScaleRight);
            
            %--------------------------------------------------------------
            % Make the MATLAB axes handles, which will display the axis of
            % the plot
            %--------------------------------------------------------------
            if ~isempty(obj.UIContextMenu)
                parUI = par;
                if strcmp(get(parUI,'type'),'uipanel')
                    parUI = get(parUI,'parent');
                end
                if parUI ~= get(obj.UIContextMenu,'parent')
                     set(obj.UIContextMenu,'parent',parUI);
                end
            end
            obj.axesHandle      = axes('units',obj.units,'position',obj.position,'parent',par,'color','none','tickDir',obj.tickDir,'yDir',obj.yDir,...
                                       'visible',obj.visible,'xScale',obj.xScale,'yScale',obj.yScale,'lineWidth',obj.lineWidth);                     
            obj.axesHandleRight = axes('units',obj.units,'position',obj.position,'parent',par,'color','none','tickDir',obj.tickDir,'yDir',obj.yDirRight,...
                                       'yAxisLocation','right','xAxisLocation','top','visible',obj.visible,'xScale',obj.xScale,...
                                       'yScale',obj.yScaleRight,'UIContextMenu', obj.UIContextMenu,'lineWidth',obj.lineWidth);
                                   
            if isprop(obj.axesHandle,'tickLength')
                set(obj.axesHandle,'tickLength',obj.tickLength);
                set(obj.axesHandleRight,'tickLength',obj.tickLength);
            end
             
            if strcmpi(obj.xTickLocation,'top')
                set(obj.axesHandle,'xTick',[]);
            else
                set(obj.axesHandleRight,'xTick',[]);
            end                       
                                   
            % Add a axes to plot the axes labels
            %--------------------------------------------------
            obj.axesLabelHandle = axes('units',         obj.units,...
                                       'color',         'none',...
                                       'parent',        par,...
                                       'position',      obj.position,...
                                       'units',         'normalized',...
                                       'visible',       'off',....
                                       'xLim',          [obj.position(1), obj.position(1) + obj.position(3)],...
                                       'yLim',          [obj.position(2), obj.position(2) + obj.position(4)]);                       
                            
            %--------------------------------------------------------------
            % Update all the axes handles, given the children of the object
            %--------------------------------------------------------------
            plotAxis(obj);
            
            % Make sure that all limits and position properties of the
            % graph objects are up to date
            %----------------------------------------------------------
            drawnow;

            %----------------------------------------------------------
            % Update the labels and titles
            %----------------------------------------------------------
            if ~isempty(obj.xLabel)
                obj.xLabel.update();
            end
            if ~isempty(obj.yLabel)
                obj.yLabel.update();
            end
            if ~isempty(obj.yLabelRight)
                obj.yLabelRight.update();
            end
            if ~isempty(obj.title)
                obj.title.update();
            end

            %----------------------------------------------------------
            % Update the legend if it is not empty 
            %----------------------------------------------------------
            if ~isempty(obj.legend)
                updateLegend(obj);
            end

            %----------------------------------------------------------
            % Update the annotations if it is not empty 
            %----------------------------------------------------------
            valid = true(1,size(obj.annotations,2));
            for ii = 1:size(obj.annotations,2)
                if ~isvalid(obj.annotations{ii})
                    valid(ii) = false;
                    continue
                end
                obj.annotations{ii}.update();
            end
            obj.annotations = obj.annotations(valid);
            
            % Add listener to the nb_figure object
            %--------------------------------------------------------------
            fig = obj.parent;
            if isa(fig,'nb_figure')
                obj.listeners = addlistener(fig,'mouseMove',@obj.notifyMouseOverObject);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the axis limits and tick marks and so on
        -------------------------------------------------------------------
        %}
        function plotAxis(obj)
            
            %--------------------------------------------------------------
            % First I need to find the axes limits of the children if not
            % given by the 'xLim' and 'yLim' property
            %--------------------------------------------------------------
            updateLimits(obj);
            
            %--------------------------------------------------------------
            % Then we must set the axes limits
            %--------------------------------------------------------------
            set(obj.plotAxesHandle,'xLim',obj.xLim,'yLim',obj.yLim);
            set(obj.axesHandle,    'xLim',obj.xLim,'yLim',obj.yLim);
            if isempty(obj.yLimRight)
                set(obj.plotAxesHandleRight,'xLim',obj.xLim,'yLim',obj.yLim);
                set(obj.axesHandleRight,    'xLim',obj.xLim,'yLim',obj.yLim);
            else
                set(obj.plotAxesHandleRight,'xLim',obj.xLim,'yLim',obj.yLimRight);
                set(obj.axesHandleRight,    'xLim',obj.xLim,'yLim',obj.yLimRight);
            end
            
            %--------------------------------------------------------------
            % Update the object stored in the 'horizontalLine',
            % 'verticalLine' and 'highlighted' properties
            %--------------------------------------------------------------
            for ii = 1:size(obj.horizontalLine,2)
                obj.horizontalLine{ii}.update();
            end
            
            for ii = 1:size(obj.verticalLine,2)
                obj.verticalLine{ii}.update();
            end
            
            for ii = 1:size(obj.highLighted,2)
                obj.highLighted{ii}.update();
            end
            
            %--------------------------------------------------------------
            % Remove the axis of the plot axes handle
            %--------------------------------------------------------------
            axis(obj.plotAxesHandle,'off');
            axis(obj.plotAxesHandleRight,'off');
            
            %--------------------------------------------------------------
            % Add the grid lines
            %--------------------------------------------------------------
            set(obj.axesHandle,...
               'gridLineStyle',obj.gridLineStyle,...
               'gridColor',obj.gridColor,...
               'xGrid',obj.grid,...
               'yGrid',obj.grid);
            
            % Do we want the axes?
            %--------------------------------------------------------------
            if strcmpi(obj.axisVisible,'off')
                
                % Remove the axis of the axes handles
                axis(obj.axesHandle,'off');
                axis(obj.axesHandleRight,'off');
                return 
            end
                
            % Needs the positions of the axes later to 
            % normalize coordinates 
            %--------------------------------------------------
            pos = get(obj.axesHandle,'position');                       
            if strcmpi(obj.xTickLocation,'top')
                axH = obj.axesHandleRight;
            else
                axH = obj.axesHandle;
            end

            %----------------------------------------------------------
            % Find out if the x-axis tick marks should be placed on the
            % base value
            %----------------------------------------------------------
            if isscalar(obj.xTickLocation) && isnumeric(obj.xTickLocation)

                notPlotXTickWAxes = 1;
                if obj.xTickSet
                    set(axH,'xTick',obj.xTick);
                else
                    obj.xTick = get(axH,'xTick');
                end
                baseValue = obj.xTickLocation;
                if baseValue > obj.yLim(1) && baseValue < obj.yLim(2)

                    if verLessThan('matlab','8.4')
                        fig = obj.parent.figureHandle;
                    else
                        if isa(obj.parent,'nb_graphPanel')
                            fig = obj.parent.panelHandle;
                        else
                            fig = obj.parent.figureHandle;
                        end
                    end

                    % Get the normalized coordinates
                    %------------------------------------------
                    base = pos(2) + (obj.xTickLocation - obj.yLim(1))*(pos(4)/(diff(obj.yLim)));
                    xx   = obj.xTick;
                    if strcmpi(obj.xScale,'log')
                        xx = log10(xx);
                    end
                    xx   = pos(1) + (xx - obj.xLim(1))*(pos(3)/(diff(obj.xLim)));
                    l    = zeros(1,length(obj.xTick) + 1);
                    for ii = 1:length(obj.xTick)
                        l(ii) = annotation(fig,'line',[xx(ii),xx(ii)],[base, base + obj.tickLength(1)],'color',[0,0,0]);                            
                    end

                    l(end) = line(obj.xLim,[baseValue baseValue],'color',[0 0 0],'parent',axH);
                    obj.tickObjects = l;

                end

            else
                notPlotXTickWAxes = 0;
            end

            %----------------------------------------------------------
            % Set the 'xTick' and the 'xTickLabel' properties of the 
            % axes if given, or else the default is used
            %----------------------------------------------------------
            if obj.xTickSet
                set(axH,'xTick',obj.xTick);
            else
                obj.xTick = get(axH,'xTick');
            end

            if ~obj.xTickVisible || notPlotXTickWAxes
                set(axH,'xTick',[]);
            end

            if obj.xTickLabelSet
                set(axH,'xTickLabel',obj.xTickLabel);
            else
                obj.xTickLabel = get(axH,'xTickLabel');
            end

            %----------------------------------------------------------
            % Set the 'yTick' and the 'yTickLabel' properties of the 
            % left axes if given, or else the default is used
            %----------------------------------------------------------
            if obj.yTickSet
                set(obj.axesHandle,'yTick',obj.yTick);
            else
                obj.yTick = get(obj.axesHandle,'yTick');
            end

            if ~obj.yTickVisible
                set(obj.axesHandle,'yTick',[]);
            end

            if obj.yTickLabelSet
                set(obj.axesHandle,'yTickLabel',obj.yTickLabel);
            else
                obj.yTickLabel = get(obj.axesHandle,'yTickLabel');
            end

            %----------------------------------------------------------
            % Set the 'yTick' and the 'yTickLabel' properties of the 
            % right axes if given, or else the default is used
            %----------------------------------------------------------
            if hasRightAxesChildren(obj) || obj.yTickRightSet || obj.yTickLabelRightSet

                if obj.yTickRightSet
                    set(obj.axesHandleRight,'yTick',obj.yTickRight);
                else
                    obj.yTickRight = get(obj.axesHandleRight,'yTick');
                end

                if ~obj.yTickVisible
                    set(obj.axesHandleRight,'yTick',[]);
                end

                if obj.yTickLabelRightSet
                    set(obj.axesHandleRight,'yTickLabel',obj.yTickLabelRight);
                else
                    obj.yTickLabelRight = get(obj.axesHandleRight,'yTickLabel');
                end

            else
                
                if obj.yTickSet
                    set(obj.axesHandleRight,'yTick',obj.yTick);
                else
                    obj.yTickRight = get(obj.axesHandleRight,'yTick');
                end

                if ~obj.yTickVisible
                    set(obj.axesHandleRight,'yTick',[]);
                end

                if obj.yTickLabelSet
                    set(obj.axesHandleRight,'yTickLabel',obj.yTickLabel);
                else
                    obj.yTickLabelRight = get(obj.axesHandleRight,'yTickLabel');
                end

            end

            % Set the x-axis and y-axis update mode to manual
            %--------------------------------------------------
            set(obj.axesHandleRight,'yTickMode','manual','xTickMode','manual');
            set(obj.axesHandle,     'yTickMode','manual','xTickMode','manual');

            % If the font size is normalized we get the font size
            % transformed to another units
            %------------------------------------------------------
            if strcmpi(obj.fontUnits,'normalized')

                axh = obj.plotAxesHandle;
                pos = get(axh,'position');
                if ~strcmpi(obj.normalized,'axes')
                    fontS  = obj.fontSize*0.8/pos(4);
                    fontSX = obj.fontSizeX*0.8/pos(4);
                else
                    fontS  = obj.fontSize;
                    fontSX = obj.fontSizeX;
                end
                fontU = obj.fontUnits;

            else
                fontU  = obj.fontUnits;
                fontS  = obj.fontSize;
                fontSX = obj.fontSizeX;
            end

            %----------------------------------------------------------
            % To create x-tick marks which is lower than default 
            %----------------------------------------------------------
            if isempty(fontSX)
                fontSX = fontS;
            end
            plotXTickMarkLabels(obj,axH,pos,fontU,fontSX,notPlotXTickWAxes)

            %---------------------------------------------------------- 
            % To create y-tick marks which is more to each side than 
            % default 
            %----------------------------------------------------------
            plotYTickMarkLabels(obj,pos,fontU,fontS)
            
            % Set aspect ratio
            %------------------------------------------------------
            if ~isempty(obj.plotBoxAspectRatio)
                set(obj.plotAxesHandle,'plotBoxAspectRatio',obj.plotBoxAspectRatio);
                set(obj.plotAxesHandleRight,'plotBoxAspectRatio',obj.plotBoxAspectRatio);
                set(obj.axesHandle,'plotBoxAspectRatio',obj.plotBoxAspectRatio);
                set(obj.axesHandleRight,'plotBoxAspectRatio',obj.plotBoxAspectRatio);
                set(obj.axesLabelHandle,'plotBoxAspectRatio',obj.plotBoxAspectRatio);
                set(obj.shadingAxes,'plotBoxAspectRatio',obj.plotBoxAspectRatio);
            end
            
        end
        
        function updateLimits(obj)
        % Get limits of axes
        
            if ~strcmpi(obj.limMode,'manual')
                
                if ~obj.yLimSet
                    obj.yLim = findYLimitsLeft(obj);
                else
                    ylim = obj.yLim;
                    if all(isnan(ylim))
                        ylimTemp = findYLimitsLeft(obj);
                        ylim     = ylimTemp;
                    elseif isnan(ylim(1))
                        ylimTemp = findYLimitsLeft(obj);
                        ylim(1)  = ylimTemp(1);
                        if ylim(1) > ylim(2)
                            ylim(1) = ylim(2) - 1;
                        end
                    elseif isnan(ylim(2))
                        ylimTemp = findYLimitsLeft(obj);
                        ylim(2)  = ylimTemp(2);
                        if ylim(1) > ylim(2)
                            ylim(2) = ylim(1) + 1;
                        end
                    end
                    obj.yLim = ylim;
                end

                if ~obj.yLimRightSet
                    obj.yLimRight = findYLimitsRight(obj);
                else
                    ylim = obj.yLimRight;
                    if all(isnan(ylim))
                        ylimTemp = findYLimitsRight(obj);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj);
                        end
                        ylim     = ylimTemp;
                    elseif isnan(ylim(1))
                        ylimTemp = findYLimitsRight(obj);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj);
                        end
                        ylim(1)  = ylimTemp(1);
                        if ylim(1) > ylim(2)
                            ylim(1) = ylim(2) - 1;
                        end
                    elseif isnan(ylim(2))
                        ylimTemp = findYLimitsRight(obj);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj);
                        end
                        ylim(2)  = ylimTemp(2);
                        if ylim(1) > ylim(2)
                            ylim(2) = ylim(1) + 1;
                        end
                    end
                    obj.yLimRight = ylim;    
                end
                
                if isempty(obj.yLimRight)
                    obj.yLimRight = obj.yLim;
                end

                if ~obj.xLimSet
                    obj.xLim = findXLimits(obj);
                else
                    xlim = obj.xLim;
                    if all(isnan(xlim))
                        xlim = findXLimits(obj);
                    elseif isnan(xlim(1))
                        xlimTemp = findXLimits(obj);
                        xlim(1)  = xlimTemp(1);
                        if xlim(1) > xlim(2)
                            xlim(1) = xlim(2) - 1;
                        end
                    elseif isnan(xlim(2))
                        xlimTemp = findXLimits(obj);
                        xlim(2)  = xlimTemp(2);
                        if xlim(1) > xlim(2)
                            xlim(2) = xlim(1) + 1;
                        end
                    end
                    obj.xLim = xlim;
                end
                
                if isnumeric(obj.alignAxes)
                    alignAxesFunction(obj)
                end
                
            end
            
        end
        
        function plotXTickMarkLabels(obj,axH,pos,fontU,fontSX,notPlotXTickWAxes)
            
            % Set the MATLAB axes properties to empty
            tempXTickLabels = cell(size(obj.xTick));
            set(axH,'xTickLabel',tempXTickLabels);
            vAlignment = 'top';
            if isempty(obj.xTick)
                return
            end

            if strcmpi(obj.xTickLabelLocation,'top')

                % Find the y-axis location of the new x-axis labels in normalized units
                y = pos(2) + pos(4) + obj.xOffset*pos(4);
                y = repmat(y,size(obj.xTick));
                vAlignment = 'bottom';

            elseif strcmpi(obj.xTickLabelLocation,'baseline')

                % Place the x-axis tick mark labels just 
                % below the baseline
                if isscalar(obj.xTickLocation)

                    % Find the y-axis location of the new x-axis labels in normalized units 
                    base = pos(2) + (obj.xTickLocation - obj.yLim(1))*(pos(4)/(diff(obj.yLim)));
                    y    = base - obj.xOffset*pos(4);
                    y    = repmat(y,size(obj.xTick));

                else % If not the xTickLocation is set to a scalar we place the x-axis tick mark labels at its default place

                    % Find the y-axis location of the new x-axis labels  in normalized units
                    y = pos(2) - obj.xOffset*pos(4);
                    y = repmat(y,size(obj.xTick));

                end

            else

                % Find the y-axis location of the new x-axis labels in normalized units
                y = pos(2) - obj.xOffset*pos(4);
                y = repmat(y,size(obj.xTick));

            end

            if strcmpi(obj.xTickLabelAlignment,'middle') 

                xx = zeros(1,length(obj.xTick));
                d  = diff(obj.xTick)/2;
                for ii = 1:length(obj.xTick) - 1
                    xx(ii) = obj.xTick(ii) + d(ii); 
                end
                xx(end) = obj.xTick(end) + d(end);

            else
                xx = obj.xTick;
            end

            % Get the alignment of the text given the rotation
            if obj.xTickRotation == 0
                alignment = 'center';
            elseif 0 < obj.xTickRotation && obj.xTickRotation < 180
                alignment  = 'right';
                vAlignment = 'middle';
            else
                alignment  = 'left';
                vAlignment = 'middle';
            end

            if ~obj.xTickLabelSet

                % Find the x-axis location of the new x-axis 
                % labels in normalized units
                xTickss = obj.xTick;
                if strcmpi(obj.xScale,'log')
                    % Correct the labels when given in log
                    xTickss = xTickss; %#ok
                    if xTickss(2) - xTickss(1) == 1
                        xTickss = 10.^(xTickss);
                    end
                end

                % Solve rounding problem
                tol          = eps^(4/7);
                ind          = xTickss < tol & xTickss > -tol;
                xTickss(ind) = 0;

                % Correct the x-axis labels given the language
                xTL = nb_num2str(xTickss(:),obj.precision);
                xTL = strtrim(cellstr(xTL));
                if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
                    xTL = strrep(xTL,'.',',');
                end
                xTL = strrep(xTL,'-',obj.dashType);

            else
                xTL = strtrim(cellstr(obj.xTickLabel));
            end

            indHBar = cellfun(@(x)isa(x,'nb_hbar'),obj.children);
            if any(indHBar)
                hBar = obj.children(indHBar);
                if numel(hBar) > 2
                    error([mfilename ':: Cannot add more than two nb_hbar object to a nb_axes object.'])
                end
                if numel(hBar) == 2

                    hBar1 = hBar{1};
                    hBar2 = hBar{2};
                    if strcmpi(hBar1.side,hBar2.side)
                        error([mfilename ':: Cannot add two nb_hbar that is plotted against the same axis.'])
                    end
                    pos     = obj.position;
                    pos1    = pos;
                    pos2    = pos;
                    pos1(3) = pos(3)/2;
                    pos2(3) = pos1(3);
                    pos2(1) = pos(1) + pos1(3);
                    set(obj.plotAxesHandle,'position',pos1);
                    set(obj.plotAxesHandleRight,'position',pos2);

                    incr = pos(3)/(length(obj.xTick)*2 - 2);
                    xx   = pos(1):incr:pos(1)+pos(3);
                    xTL  = [xTL;flipud(xTL(1:end-1))];
                    xTL  = xTL(1:2:end);
                    xx   = xx(1:2:end);
                    y    = repmat(y(1),[1,length(xTL)]);
                    
                else
                    
                    hBar1 = hBar{1};
                    if strcmpi(hBar1.side,'right')
                        xx = fliplr(xx);
                    end
                    
                    % Get the normalized coordinates
                    %----------------------------------------------
                    if strcmpi(obj.xScale,'log')
                        xx = log10(xx);
                        xx = pos(1) + (xx - log10(obj.xLim(1)))*(pos(3)/(diff(log10(obj.xLim))));
                    else
                        xx = pos(1) + (xx - obj.xLim(1))*(pos(3)/(diff(obj.xLim)));
                    end
                    
                end
                
                if obj.xTickVisible && ~notPlotXTickWAxes
                    if numel(hBar) == 2
                        xLimA = get(obj.axesHandle,'XLim');
                        incr  = xLimA(2)/(length(obj.xTick)*2 - 2);
                        xxx   = xLimA(1):incr:xLimA(2);
                        xxx   = xxx(1:2:end);
                        set(obj.axesHandle,'xTick',xxx);
                    else
                        set(obj.axesHandle,'xTick',obj.xTick);
                    end
                end
                set(obj.axesHandle,'xTickLabel',cell(size(xx)));
                
            else
                if obj.xTickVisible && ~notPlotXTickWAxes
                    set(obj.axesHandle,'xTick',obj.xTick);
                end
                set(obj.axesHandle,'xTickLabel',cell(size(xx)));
                
                % Get the normalized coordinates
                %----------------------------------------------
                if strcmpi(obj.xScale,'log')
                    xx = log10(xx);
                    xx = pos(1) + (xx - log10(obj.xLim(1)))*(pos(3)/(diff(log10(obj.xLim))));
                else
                    xx = pos(1) + (xx - obj.xLim(1))*(pos(3)/(diff(obj.xLim)));
                end
                
            end

            if ~isempty(xTL)

                t = zeros(1,length(xx));

                try

                    for ii = 1:length(xx)

                        % Plot the x-axis tick mark labels
                        t(ii) = text(xx(ii),y(ii),xTL{ii},...
                                'HorizontalAlignment'  ,alignment,...
                                'VerticalAlignment'    ,vAlignment,...
                                'interpreter'          ,obj.xTickLabelInterpreter,...
                                'fontWeight'           ,obj.fontWeight,...
                                'fontName'             ,obj.fontName,...
                                'fontUnits'            ,fontU,...
                                'fontSize'             ,fontSX,...
                                'parent'               ,obj.axesLabelHandle,...
                                'rotation'             ,obj.xTickRotation,...
                                'visible'              ,obj.visible);

                    end

                catch Err

                    if length(xx) ~= length(xTL)
                        error([mfilename ':: The number of x-axis mark labels don''t match the number of tick marks. '...
                                         '(I.e. length(obj.xTick) ~= length(obj.xTickLabel))'])
                    else
                        rethrow(Err)
                    end

                end   
                obj.xTickLabelObjects = t;

            end
            
        end
        
        function plotYTickMarkLabels(obj,pos,fontU,fontS)
            
            %.......................................................... 
            % Left axes
            %..........................................................
            if ~obj.yTickLabelSet

                % Do a rounding of the scales to remove some annoying
                % cases where you get too large precision
                yTickssT      = obj.yTick;
                tol           = eps^(4/7);
                ind           = yTickssT < tol & yTickssT > -tol;
                yTickssT(ind) = 0;

                % Correct the y-axis labels given the language
                yTL = nb_num2str(yTickssT(:),obj.precision);
                yTL = strtrim(cellstr(yTL));
                if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
                    yTL = strrep(yTL,'.',',');
                end
                yTL = strrep(yTL,'-',obj.dashType);

            else
                yTL = strtrim(cellstr(obj.yTickLabel));
            end

            % Find the y-axis location of the new y-axis 
            % labels in normalized units
            yTickss = obj.yTick;
            if obj.yTickVisible
                set(obj.axesHandle,'yTick',yTickss);
            end

            if strcmpi(obj.yScale,'log')
                yTickss = log10(yTickss);
                yTickss = pos(2) + (yTickss - log10(obj.yLim(1)))*(pos(4)/(diff(log10(obj.yLim))));
            else
                yTickss = pos(2) + (yTickss - obj.yLim(1))*(pos(4)/(diff(obj.yLim)));
            end

            % Set the MATLAB axes properties to empty
            set(obj.axesHandle,'yTickLabel',cell(size(yTickss)));
            if strcmpi(obj.yDir,'reverse')
                yTL = flipud(yTL);
            end

            if ~isempty(yTickss) && ~isempty(yTL)

                % Find the x-axis location of the new x-axis 
                % labels in normalized units
                x = pos(1) - obj.yOffset*pos(3);
                t = nan(1,length(yTL));
                try

                    for ii = 1:length(yTL)

                        t(ii) = text(x,yTickss(ii),yTL{ii},...
                                    'horizontalAlignment'  ,'right',...
                                    'verticalAlignment'    ,'middle',...
                                    'interpreter'          ,obj.yTickLabelInterpreter,...
                                    'fontName'             ,obj.fontName,...
                                    'fontWeight'           ,obj.fontWeight,...
                                    'fontUnits'            ,fontU,...
                                    'fontSize'             ,fontS,...
                                    'parent'               ,obj.axesLabelHandle,...
                                    'visible'              ,obj.visible);        

                    end

                catch Err

                    if length(yTickss) ~= length(yTL)
                        error([mfilename ':: The number of y-axis (left) mark labels don''t match the number of tick marks. '...
                                         '(I.e. length(obj.yTick) ~= length(obj.yTickLabel))'])
                    else
                        rethrow(Err)
                    end

                end
                obj.yTickLabelObjects = t;

            end

            %..........................................................
            % Right axes
            %..........................................................
            if ~obj.yTickLabelRightSet

                % Do a rounding of the scales to remove some annoying
                % cases where you get too large precision
                yTickssT      = obj.yTickRight;
                tol           = eps^(4/7);
                ind           = yTickssT < tol & yTickssT > -tol;
                yTickssT(ind) = 0;

                % Correct the y-axis labels given the language
                yTL = nb_num2str(yTickssT(:),obj.precision);
                yTL = strtrim(cellstr(yTL));
                if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
                    yTL = strrep(yTL,'.',',');
                end
                yTL = strrep(yTL,'-',obj.dashType);

            else
                yTL = strtrim(cellstr(obj.yTickLabelRight));
            end

            % Find the y-axis location of the new y-axis 
            % labels in normalized units
            yTickss = obj.yTickRight;
            if obj.yTickVisible
                set(obj.axesHandleRight,'yTick',yTickss);
            end

            if strcmpi(obj.yScaleRight,'log')
                yTickss = log10(yTickss);
                yTickss = pos(2) + (yTickss - log10(obj.yLimRight(1)))*(pos(4)/(diff(log10(obj.yLimRight))));
            else
                yTickss = pos(2) + (yTickss - obj.yLimRight(1))*(pos(4)/(diff(obj.yLimRight)));
            end

            % Set the MATLAB axes properties to empty
            set(obj.axesHandleRight,'yTickLabel',cell(size(yTickss)));
            if strcmpi(obj.yDirRight,'reverse')
                yTL = flipud(yTL);
            end

            if ~isempty(yTL) && ~isempty(yTickss)

                % Find the x-axis location of the new x-axis 
                % labels in normalized units
                x = pos(1) + pos(3) + obj.yOffset*pos(3);

                % Plot the y-axis tick mark labels (Right side)
                t = nan(1,length(yTL));
                try

                    for ii = 1:length(yTL)

                        t(ii) = text(x,yTickss(ii),yTL{ii},...
                                    'horizontalAlignment'  ,'left',...
                                    'verticalAlignment'    ,'middle',...
                                    'fontName'             ,obj.fontName,...
                                    'fontWeight'           ,obj.fontWeight,...
                                    'fontUnits'            ,fontU,...
                                    'fontSize'             ,fontS,...
                                    'Parent'               ,obj.axesLabelHandle,...
                                    'visible'              ,obj.visible);        

                    end

                catch Err

                    if length(yTickss) ~= length(yTL)
                        error([mfilename ':: The number of y-axis (right) mark labels don''t match the number of tick marks. '...
                                         '(I.e. length(obj.yTickRight) ~= length(obj.yTickLabelRight))'])
                    else
                        rethrow(Err)
                    end

                end
                obj.yTickLabelRightObjects = t;

            end
            
        end
            
        
        %{
        -------------------------------------------------------------------
        Find out if there are some plotted handles on the right axes
        -------------------------------------------------------------------
        %}
        function ret = hasRightAxesChildren(obj)
            
            ret = 0;
            for ii = 1:size(obj.children,2)
                
                side = get(obj.children{ii},'side');
                if strcmpi(side,'right')
                    ret  = 1;
                    break;
                end
                
            end
            
        end
        
        %------------------------------------------------------------------
        % Add shading
        %------------------------------------------------------------------
        function addShading(obj)
            
            if isempty(obj.shadingAxes) || ~ishandle(obj.shadingAxes)
                
                if isa(obj.parent,'nb_figure')
                    if isa(obj.parent,'nb_graphPanel')
                        par = obj.parent.panelHandle;
                    else
                        par = obj.parent.figureHandle;
                    end
                else
                    par = obj.parent;
                end
                obj.shadingAxes = axes('parent',par,'color','none','units','normalized');
                
            end
            
            set(obj.shadingAxes,'units',obj.units);
            set(obj.shadingAxes,'position',obj.position,'visible',obj.visible);
            
            if strcmpi(obj.axisVisible,'off')
                
                if strcmpi(obj.color,'none')
                    set(get(obj.shadingAxes,'children'),'visible','off');
                end
                
            else
                
                if ~isempty(obj.imageChild)
                
                    if ~isempty(obj.imageHandle)
                        if ishandle(obj.imageHandle)
                            delete(obj.imageHandle)
                        end
                    end
                    
                    obj.imageChild.cData;
                    if size(obj.imageChild.cData,3) == 1
                        % Map using the current color map
                        obj.imageHandle = imagesc(obj.imageChild.cData,'parent',obj.shadingAxes);
                        cMap            = getColorMap(obj);
                        if obj.imageChild.appendWhite
                           cMap = [1,1,1; cMap]; 
                        end
                        colormap(obj.shadingAxes,cMap);
                    else
                        obj.imageHandle = image(obj.imageChild.cData,'parent',obj.shadingAxes);
                    end
                    
                elseif isnumeric(obj.shading)
            
                    % Numeric shading constructed by the user
                    image(uint8(obj.shading*255),'parent',obj.shadingAxes,'visible',obj.visible);
                    
                else
                    
                    switch obj.shading

                        case {'grey','grå','gr'}

                            % Define grey shading
                            grad = zeros(256,1,3);

                            startP  = 75;
                            startPF = 0.4; 
                            for i=1:startP
                                grad(i,1,1) = 155 + 100*(256 - i*startPF)/255;
                                grad(i,1,2) = 155 + 100*(256 - i*startPF)/255;
                                grad(i,1,3) = 155 + 100*(256 - i*startPF)/255;
                            end

                            midP  = 106;
                            midPF = 0.9;
                            for i=1:midP
                                grad(i + startP,1,1) = 155 + 100*(256 - startP*startPF - i*midPF)/255;
                                grad(i + startP,1,2) = 155 + 100*(256 - startP*startPF - i*midPF)/255;
                                grad(i + startP,1,3) = 155 + 100*(256 - startP*startPF - i*midPF)/255;
                            end

                            endP  = 75;
                            endPF = 0.4;
                            for i=1:endP
                                grad(i + startP + midP,1,1) = 155 + 100*(256 - startP*startPF - midP*midPF - i*endPF)/255;
                                grad(i + startP + midP,1,2) = 155 + 100*(256 - startP*startPF - midP*midPF - i*endPF)/255;
                                grad(i + startP + midP,1,3) = 155 + 100*(256 - startP*startPF - midP*midPF - i*endPF)/255;
                            end

                            image(uint8(grad),'parent',obj.shadingAxes,'visible',obj.visible);

                        case {'none'}

                            if ~strcmpi(obj.color,'none')

                                grad = zeros(256,1,3);
                                for ii = 1:256
                                    grad(ii,1,:) = obj.color*255;
                                end
                                image(uint8(grad),'parent',obj.shadingAxes,'visible',obj.visible);

                            end


                        otherwise

                            error([mfilename ':: No shading type ''' obj.shading ''' supported for this class.'])

                    end
                    
                end
                
            end
            
            % Remove the axis of this axes handle
            axis(obj.shadingAxes,'off');
            
        end
        
        function alignAxesFunction(obj)

            % Here we align the axes at a base value
            baseValue = obj.alignAxes;
            if isempty(baseValue)
                return
            end
            if isscalar(baseValue)
                baseValue = [baseValue,baseValue];
            end
            if ~nb_sizeEqual(baseValue,[1,2])
                error([mfilename ':: The ''alignAxes'' input must be either be a scalar or a 1x2 double.'])
            end
            ylim      = obj.yLim;
            ylimR     = obj.yLimRight;
            d1        = ylim(1) - baseValue(1);
            d2        = ylim(2) - baseValue(1);
            dr1       = ylimR(1) - baseValue(2);
            dr2       = ylimR(2) - baseValue(2);
            
            if strcmpi(obj.yDir,'reverse') && ~strcmpi(obj.yDirRight,'reverse')
                dt = d1;
                d1 = -d2;
                d2 = -dt;
            elseif ~strcmpi(obj.yDir,'reverse') && strcmpi(obj.yDirRight,'reverse')
                dt  = dr1;
                dr1 = -dr2;
                dr2 = -dt;
            end
            
            if d1 >= 0
            
                if dr1 >= 0
                    ylim(1)  = baseValue(1);
                    ylimR(1) = baseValue(2); 
                elseif dr2 <= 0
                    % Do nothing, strange case...
                else
                    ratio    = d2/dr2;
                    ylim(1)  = baseValue(1) + ratio*dr1;
                end
                
            elseif d2 <= 0
                
                if dr1 >= 0
                    % Do nothing, strange case...
                elseif dr2 <= 0
                    ylim(2)  = baseValue(1);
                    ylimR(2) = baseValue(2); 
                else
                    ratio    = d1/dr1;
                    ylim(2)  = baseValue(2) + ratio*dr2;
                end
            
            else
                
                if dr1 >= 0
                    ratio    = dr2/d2;
                    ylimR(1) = baseValue(2) + ratio*d1;
                elseif dr2 <= 0
                    ratio    = dr1/d1;
                    ylimR(2) = baseValue(2) + ratio*d2;
                else
                    r1 = abs(d1/d2);
                    r2 = abs(dr1/dr2);
                    if r1 <= 1 && r2 > 1
                        
                        if 1/r2 < r1
                            ratio    = dr1/d1;
                            ylimR(2) = baseValue(2) + ratio*d2;
                        else
                            ratio   = d2/dr2;
                            ylim(1) = baseValue(1) + ratio*dr1;
                        end
                        
                    elseif r1 > 1 && r2 > 1
                        
                        if r2 > r1
                            ratio    = dr1/d1;
                            ylimR(2) = baseValue(2) + ratio*d2;
                        else
                            ratio   = d1/dr1;
                            ylim(2) = baseValue(1) + ratio*dr2;
                        end    
                        
                    elseif r1 > 1 && r2 <= 1
                        
                        if 1/r2 < r1
                            ratio   = d1/dr1;
                            ylim(2) = baseValue(1) + ratio*dr2;
                        else
                            ratio    = dr2/d2;
                            ylimR(1) = baseValue(2) + ratio*d1;
                        end
                        
                    elseif r1 <= 1 && r2 <= 1
                        
                        if r2 > r1
                            ratio   = d2/dr2;
                            ylim(1) = baseValue(1) + ratio*dr1;
                        else
                            ratio    = dr2/d2;
                            ylimR(1) = baseValue(2) + ratio*d1;
                        end    
                        
                    end
                    
                end
                      
            end
            
            obj.yLim      = ylim;
            obj.yLimRight = ylimR;
            
        end
            
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        function colors = defaultColorMap() 
            r_spectrum = linspace(0.8039,0.1333,99)';
            g_spectrum = linspace(0.5490,0.3490,99)';   
            b_spectrum = linspace(0.2549,0.4706,99)';
            colors     = [r_spectrum,g_spectrum,b_spectrum];
        end

    end
    
end
    
