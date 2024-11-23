classdef nb_listbox < nb_settable & nb_getable
% Description:
%
% Create list box with more options than what is supported with the
% standrard uicontrol('style','listbox').
%
% Caution: This object sets the following callback function of the parent,
%          if the parent is a MATLAB graphics handle, 
%          'WindowButtonDownFcn', 'WindowButtonUpFcn', 
%          'WindowButtonMotionFcn', 'keyPressFcn' and 'keyReleaseFcn'.
%
% Tip: To include more nb_listbox objects in one graph use a nb_figure
%      object as main parent!
%
% Superclasses:
%
% nb_settable, nb_getable, handle
%
% Constructor:
%
%   obj = nb_listbox
%   obj = nb_listbox(parent)
%   obj = nb_listbox(parent, varargin)
%   obj = nb_listbox(varargin)
% 
%   Input:
%
%   - parent   : A nb_figure, figure or uipanel object.
% 
%   - varargin : Optional inputs given to the set method.
%
%   Output:
%
%   - obj    : An object of class nb_listbox.
% 
%   Examples:
% 
% See also: 
% uicontrol
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)
        
        % The selection index. See also the selection property.
        value   
        
    end

    properties (Dependent=true,SetAccess=protected)
        
        % A vector of matlab.ui.control.WebComponent objects.
        children
        
        % Height of icons including margins.
        elementHeight 
       
        % Width of icons including margins.
        elementWidth 
         
    end

    properties
        
        % Background color of listbox. Must be a 1 x 3 double with the RGB
        % colors. Default is [1,1,1].
        backgroundColor     = [1,1,1];
        
        % Color of border line. A 1x3 double with the RGB colors. 
        borderColor         = [0,0,0];
        
        % Border line style. Default is '-'.
        borderLineStyle     = '-';
        
        % Border line width. Default is 0.5.
        borderLineWidth     = 0.5;
        
        % Margin between panel and border line in pixels. Default is .
        borderMargin        = 2;
        
        % Foreground color of listbox, i.e. color of the text (when not 
        % selected). Must be a 1 x 3 double with the RGB colors. Default 
        % is [0,0,0].
        foregroundColor     = [0,0,0];
        
        % High of icon of each row of the list box in pixels.
        iconHeight          = 13;
        
        % Width of icon of each row of the list box in pixels.
        iconWidth           = 13;
        
        % A cell vector with the images of the icons of the text to list.
        % If a empty element is given, no icon will be displayed. Each
        % element must either be a image as a N x M double or on of:
        %
        % > 'xls'    : Excel icon.
        %
        % Caution: If this input has more elements than the string property
        % the last entries will be discarded, if it has less elements it
        % will be expanded with empty elements.
        icons               = {};
        
        % Margin between icon and edges and text.
        margin              = 2;
        
        % The parent of the list box. Either an object of class nb_figure,
        % figure or uipanel.
        parent              = [];
        
        % Position as a 1x4 double [left,bottom,width,height].
        position            = [0.1,0.1,0.5,0.5];
        
        % Scrollbar color, as 1x3 double with the RGB colors. Default is
        % [1,1,1].
        scrollBarColor      = [1,1,1];
        
        % Scroll bar width in pixels. Default is 15.
        scrollBarWidth      = 15;
        
        % Selection highlight color
        selectionColor      = [34, 89, 120]/255;
        
        % A 1 x N or N x 1 cellstr vector with the text of the list.
        string              = {};
        
        % Add title to the list box, as a one line char.
        title               = '';
        
        % Handle to the text object of the title. Do not set the 'parent'
        % property! This property can be used to set properties of the
        % title, such as color and font size.
        titleHandle         = []; 
        
        % Sets the uicontextmenu handle related to the this object 
        UIContextMenu       = [];
       
    end
    
    properties (SetAccess=protected)
    
        % Selection, as a 1 x N logical. Element is true if selected.
        % See also the value property. Not settable.
        selection           = [];
        
    end
    
    properties (Access=protected)
       
        % Images
        images              = struct('xls','xls.jpg','fame','fame.jpg','graph','graph.jpg',...
                                     'graph_panel','graph_panel.jpg','mat','mat.jpg',...
                                     'model','model.jpg','model_group','model_group.jpg',...
                                     'package','package.jpg','smart','smart.jpg',...
                                     'adv_graph','adv_graph.jpg','data','data.jpg',...
                                     'adv_table','adv_table.jpg','table','table.jpg',...
                                     'combined','combined.jpg');
        loadedImages        = struct();
        imageIdentifier     = {};
        
        % Measures
        left2Slide          = 0;
        mainPosition        = [];
        
        % Protected UI handles 
        borderAxes          = [];
        borderLine          = [];
        buttonHandles       = [];
        imageHandles        = [];
        mainUIPanel         = [];
        scrollListener      = [];
        scrollUIControl     = [];
        textAxes            = [];
        textHandles         = [];
        
        % Other
        underConstruction   = true;
        
        % Selection
        selectionStartPoint = 0;
        moved               = 0;
        
    end
    
    properties (Access=protected,Dependent=true)
       
        % A matlab figure or uipanel handle.
        matlabParent        = []; 
        
    end
    
    methods
        
        function obj = nb_listbox(varargin)
                        
            if nargin == 0
                obj.parent = figure();
            else
                if any(strcmpi(class(varargin{1}),{'matlab.ui.Figure','matlab.ui.container.Panel','nb_figure'}))
                    obj.doUpdate = false; % Will be reset in the set method!
                    obj.parent   = varargin{1};
                    varargin     = varargin(2:end);
                end
            end  
            set(obj,varargin);
            
        end
        
        %==================================================================
        % Get methods
        %==================================================================
        
        function value = get.children(obj)
            value = [obj.borderAxes;obj.borderLine;obj.buttonHandles';...
                     obj.imageHandles';obj.mainUIPanel;obj.scrollUIControl;...
                     obj.textAxes; obj.textHandles';obj.titleHandle];
        end
        
        function value = get.elementHeight(obj)
            value = obj.iconHeight + obj.margin*2; 
        end
        
        function value = get.elementWidth(obj)
            value = obj.iconWidth + obj.margin*2;
        end
        
        function value = get.matlabParent(obj)
        
            if isa(obj.parent,'nb_figure')
                value = obj.parent.figureHandle;
            else
                value = obj.parent;
            end
            
        end
        
        function val = get.value(obj)
            if isempty(obj.selection)
                val = [];
            else
                val = find(obj.selection);
            end
        end
        
        %==================================================================
        % Set methods
        %==================================================================
        
        function set.backgroundColor(obj,value)
            
            if ~nb_isRGB(value)
                error([mfilename ':: backgroundColor must be set to a RGB color.'])
            end
            obj.backgroundColor = value;
            obj.update();
            
        end
        
        function set.borderColor(obj,value)
            
            if ~nb_isRGB(value)
                error([mfilename ':: borderColor must be set to a RGB color.'])
            end
            obj.borderColor = value;
            obj.update();
            
        end
        
        function set.borderLineStyle(obj,value)
            
            if ~nb_islineStyle(value)
                error([mfilename ':: borderLineStyle must be set to a valid line style.'])
            end
            obj.borderLineStyle = value;
            obj.update();
            
        end
        
        function set.borderLineWidth(obj,value)
            
            if ~nb_isScalarNumber(value) || any(value <= 0)
                error([mfilename ':: borderLineWidth must be set to a positive scalar number.'])
            end
            obj.borderLineWidth = value;
            obj.update();
            
        end
        
        function set.borderMargin(obj,value)
            
            if ~nb_isScalarNumber(value) || any(value <= 0)
                error([mfilename ':: borderMargin must be set to a positive scalar number.'])
            end
            obj.borderMargin = value;
            obj.update();
            
        end
        
        function set.foregroundColor(obj,value)
            
            if ~nb_isRGB(value)
                error([mfilename ':: foregroundColor must be set to a RGB color.'])
            end
            obj.foregroundColor = value;
            obj.update();
            
        end
        
        function set.iconHeight(obj,value)
            
            if ~nb_isScalarNumber(value) || any(value <= 0)
                error([mfilename ':: iconHeight must be set to a positive scalar number.'])
            end
            obj.iconHeight = value;
            obj.update();
            
        end
        
        function set.iconWidth(obj,value)
            
            if ~nb_isScalarNumber(value) || any(value <= 0)
                error([mfilename ':: iconWidth must be set to a positive scalar number.'])
            end
            obj.iconWidth = value;
            obj.update();
            
        end
        
        function set.icons(obj,value)
           
            if ischar(value)
                value = {value};
            elseif ~iscell(value)
                error([mfilename ':: The property icons must be set to a cell.'])
            end
            obj.icons = value(:);
            loadImages(obj);
            update(obj);
            
        end
        
        function set.margin(obj,value)
            
            if ~nb_isScalarNumber(value) || any(value <= 0)
                error([mfilename ':: margin must be set to a positive scalar number.'])
            end
            obj.margin = value;
            obj.update();
            
        end
        
        function set.parent(obj,value)
           
            if not(nb_isUipanel(value) || nb_isFigure(value) || isa(value,'nb_figure'))
                error([mfilename ':: The property parent must be set to figure, uipanel or nb_figure object.'])
            end
            obj.parent = value;  
            addButtonDownCallback(obj);
            obj.update();
            
        end
        
        function set.position(obj,value)
            
            if ~isnumeric(value) || ~nb_sizeEqual(value,[1,4])
                error([mfilename ':: position must be set to a 1 x 4 double [x,y,dx,dy].'])
            end
            obj.position = value;
            obj.update();
            
        end
        
        function set.scrollBarColor(obj,value)
            
            if ~nb_isRGB(value)
                error([mfilename ':: scrollBarColor must be set to a RGB color.'])
            end
            obj.scrollBarColor = value;
            obj.update();
            
        end
        
        function set.scrollBarWidth(obj,value)
            
            if ~nb_isScalarNumber(value) || any(value <= 0)
                error([mfilename ':: scrollBarWidth must be set to a positive scalar number.'])
            end
            obj.scrollBarWidth = value;
            obj.update();
            
        end
        
        function set.selectionColor(obj,value)
            
            if ~nb_isRGB(value)
                error([mfilename ':: selectionColor must be set to a RGB color.'])
            end
            obj.selectionColor = value;
            obj.update();
            
        end
        
        function set.string(obj,value)
           
            if ischar(value)
                value = cellstr(value);
            elseif ~iscellstr(value)
                 error([mfilename ':: The property string must be set to a cellstr.'])
            end
            obj.string = value(:);
            obj.update();
            
        end

        function set.title(obj,value)
           
            if ischar(value)
                value = cellstr(value);
            elseif ~iscellstr(value)
                 error([mfilename ':: The property title must be set to a char or cellstr.'])
            end
            obj.title = value;
            obj.update();
            
        end
        
        function set.UIContextMenu(obj,value)
           
            if ~nb_isContextMenu(value)
                error([mfilename ':: The property UIContextMenu must be set to a ContextMenu object.'])
                
            end
            obj.UIContextMenu = value;
            obj.update();
            
        end
        
        function set.value(obj,val)
            
            val = val(:);
            if ~nb_iswholenumber(val)
                error([mfilename ':: The value property must be set to a integer.'])
            end
            if any(val < 1)
                error([mfilename ':: The value property must be set to a integer greater than 1.'])
            end
            if any(val > length(obj.string))
                error([mfilename ':: The value property must be set to a integer less than the number ',...
                                 'of listed elements (' int2str(length(obj.string)) ').'])
            end
            obj.selection(val(end)) = true; % TO DO: Make it possible to select more than one element!
            
        end
        
        
    end
    
    methods (Access=protected)
        
        update(obj)
        
        function updateCallback(obj,~,~)
            if ~obj.underConstruction 
                update(obj);
            end
        end
        
        function sliderCallback(obj,~,~)
            updateList(obj,true); 
        end
        
        function updateList(obj,insideSlider)
            
            if obj.left2Slide == 0
                obj.moved = 0;
                resValue  = 0;
            else
                slideValue = get(obj.scrollUIControl,'value');
                resValue   = rem(round(obj.left2Slide - slideValue),obj.elementHeight);
                obj.moved  = floor(round(obj.left2Slide - slideValue)/obj.elementHeight);
            end
            
            if length(obj.selection) ~= length(obj.string)
                obj.selection = false(1,length(obj.string));
            end
            
            % Get the coordinates in pixels
            yInP = obj.mainPosition(4);
            num  = ceil(yInP/obj.elementHeight);
            y    = nan(num,1);
            y(1) = obj.mainPosition(4) - obj.elementHeight/2;
            for ii = 2:num
                y(ii) = y(ii-1) - obj.elementHeight;
            end
            y = y + resValue;
            
            % Button y locations
            yButton = y - obj.elementHeight/2 + (obj.elementHeight - obj.iconHeight)/2;

            % Map to normalized units
            yNorm = nb_pos2pos(y,[0,obj.mainPosition(4)],[0,1],'normal','normal');

            % Plot the text
            iterate  = min(num,length(obj.string));
            xNorm    = nb_dpos2dpos(obj.elementWidth,[0,obj.mainPosition(3)],[0,1],'normal','normal');
            if insideSlider && length(obj.textHandles) == iterate
                for ii = 1:iterate
                    set(obj.textHandles(ii),'position',[xNorm,yNorm(ii),0],'string',obj.string{ii + obj.moved});
                    set(obj.buttonHandles(ii),'position',[obj.margin, yButton(ii), obj.iconWidth, obj.iconHeight]);
                    if obj.selection(ii + obj.moved)
                        set(obj.textHandles(ii),'color',obj.selectionColor,'fontWeight','bold'); 
                    else
                        set(obj.textHandles(ii),'color',obj.foregroundColor,'fontWeight','normal'); 
                    end
                end
            else
                
                % Text boxes
                if ~isempty(obj.textHandles)
                    delete(obj.textHandles);
                end
                tHandles = nb_gobjects(1,iterate);
                for ii = 1:iterate
                    tHandles(ii) = text(xNorm,yNorm(ii),obj.string{ii + obj.moved},...
                                'parent',        obj.textAxes,...
                                'UIContextMenu', obj.UIContextMenu,...
                                'interpreter',   'none');
                    if obj.selection(ii + obj.moved)
                        set(tHandles(ii),'color',obj.selectionColor,'fontWeight','bold'); 
                    else
                        set(tHandles(ii),'color',obj.foregroundColor,'fontWeight','normal'); 
                    end        
                end
                obj.textHandles = tHandles;
                
                % Icon boxes
                if ~isempty(obj.buttonHandles)
                    delete(obj.buttonHandles);
                end
                bHandles = nb_gobjects(1,iterate);
                for ii = 1:iterate
                    bHandles(ii) = nb_blankAxes(obj.mainUIPanel,...
                        'units',    'pixels',...
                        'position', [obj.margin, yButton(ii), obj.iconWidth, obj.iconHeight]);
                end
                obj.buttonHandles = bHandles;
                
            end
            
            % Place icons on the buttons
            if ~isempty(obj.imageHandles)
                delete(obj.imageHandles);
            end
            if ~isempty(obj.imageIdentifier)
                iHandles = nb_gobjects(1,iterate);
                for ii = 1:iterate
                    if ~isempty(obj.imageIdentifier{ii + obj.moved})
                        iHandles(ii) = imshow(obj.loadedImages.(obj.imageIdentifier{ii + obj.moved}),'parent',obj.buttonHandles(ii));
                    end
                end
                obj.imageHandles = iHandles;
            else
                obj.imageHandles = [];
            end
             
        end
        
        function plotBorderLine(obj)
        % Plot a line that wraps around the axes
        
            props = struct(...    
                'color',      obj.borderColor,...
                'lineStyle',  obj.borderLineStyle,...
                'lineWidth',  obj.borderLineWidth );
            if isempty(obj.borderLine)
                x              = [0,1,1,0,0];
                y              = [0,0,1,1,0];
                obj.borderLine = line(x,y,...
                    'parent',obj.borderAxes,...
                    props);
            else
                set(obj.borderLine,props);
            end
            
        end
        
        function loadImages(obj)
            
            if isempty(obj.icons)
                return
            end
           
            obj.imageIdentifier = cell(1,length(obj.string));
            userDefinedInd      = 1;
            for ii = 1:length(obj.icons)
                
                if isempty(obj.icons{ii})
                    obj.imageIdentifier{ii} = '';
                elseif ischar(obj.icons{ii})
                    
                    obj.imageIdentifier{ii} = obj.icons{ii};
                    if isfield(obj.loadedImages,obj.icons{ii})
                        continue
                    end
                    try
                        obj.loadedImages.(obj.icons{ii}) = imread(obj.images.(obj.icons{ii}));
                    catch
                        error([mfilename ':: The icon ' obj.icons{ii} ' is not supported'])
                    end
                    
                elseif isnumeric(obj.icons{ii})
                    userDefName                    = ['userDefined' int2str(userDefinedInd)];
                    obj.loadedImages.(userDefName) = obj.icons{ii}; 
                    obj.imageIdentifier{ii}        = userDefName; 
                    userDefinedInd                 = userDefinedInd + 1;
                end
                
            end
            
        end
        
        function addButtonDownCallback(obj)
            
            switch class(obj.parent)
                case 'matlab.ui.Figure'
                    set(obj.parent,'WindowButtonDownFcn',@obj.selectionDownCallback);
                    set(obj.parent,'WindowButtonUpFcn',@obj.selectionUpCallback);
                    %set(obj.parent,'WindowButtonMotionFcn',@obj.selectionDownCallback);
                    %set(obj.parent,'keyPressFcn',@obj.selectionDownCallback);
                    %set(obj.parent,'keyReleaseFcn',@obj.selectionDownCallback);
                case 'matlab.ui.container.Panel'
                    figH = nb_getParentRecursively(obj.parent);
                    set(figH,'WindowButtonDownFcn',@obj.selectionDownCallback);
                    set(figH,'WindowButtonUpFcn',@obj.selectionUpCallback);
                    %set(figH,'WindowButtonMotionFcn',@obj.selectionDownCallback);
                    %set(figH,'keyPressFcn',@obj.selectionDownCallback);
                    %set(figH,'keyReleaseFcn',@obj.selectionDownCallback);
                case 'nb_figure'
                    addlistener(obj.parent,'mouseDown',@obj.selectionDownCallback);
                    addlistener(obj.parent,'mouseUp',@obj.selectionUpCallback);
                    %addlistener(obj.parent,'mouseMove',@obj.selectionDownCallback);
                    %addlistener(obj.parent,'keyPress',@obj.selectionDownCallback);
                    %addlistener(obj.parent,'keyRelease',@obj.selectionDownCallback);
            end
        end
        
        function selectionDownCallback(obj,fig,~)
            
            % Get current point in the units of the listbox
            [~,cPoint]              = nb_getCurrentPointInAxesUnits(fig,obj.mainUIPanel);
            obj.selectionStartPoint = cPoint(2);
            
        end
        
        function selectionUpCallback(obj,fig,~)
            
            % Get current point in the units of the listbox
            [~,endPoint] = nb_getCurrentPointInAxesUnits(fig,obj.mainUIPanel);
            if endPoint(1) < 0 || endPoint(1) > 1
                return
            end
            endPoint = endPoint(2);
            maxPoint = endPoint; %max(obj.selectionStartPoint,endPoint);
            minPoint = endPoint; %min(obj.selectionStartPoint,endPoint);

            % Highlight the selected element
            sel = false(1,length(obj.string));
            for ii = 1:length(obj.textHandles)
                
                ext = get(obj.textHandles(ii),'extent');
                if ext(2) < maxPoint && ext(2) + ext(4) > minPoint
                    sel(ii + obj.moved) = true;
                    break;
                end
                
            end
            
            % Do selection
            selOld = obj.selection(obj.moved + 1:obj.moved + length(obj.textHandles));
            if any(selOld)
                set(obj.textHandles(selOld),'color',obj.foregroundColor,'fontWeight','normal'); 
            end
            if any(sel)
                set(obj.textHandles(ii),'color',obj.selectionColor,'fontWeight','bold');
            end
            
            % Set the new selection
            obj.selection = sel;
            
        end
          
    end
    
    methods (Static=true)
       
        function obj = test()
           
            num     = 20;
            str     = cell(20,1);
            iconsEx = cell(20,1);
            for ii = 1:num
                str{ii} = ['Test ' int2str(ii)];
            end
            str{1}      = 'sdfdfdfdfsdfsdfdgfsdgdgfsdgsdgsdgsdg';
            iconsEx{1}  = 'smart';
            iconsEx{2}  = 'mat';
            iconsEx{3}  = 'fame';
            iconsEx{4}  = 'xls';
            iconsEx{5}  = 'data';
            iconsEx{6}  = 'graph';
            iconsEx{7}  = 'adv_graph';
            iconsEx{8}  = 'graph_panel';
            iconsEx{10} = 'package';
            iconsEx{11} = 'model';
            iconsEx{12} = 'model_group';
            obj = nb_listbox('string',str,'icons',iconsEx,'title','Test');
            
        end
        
    end
    
end

