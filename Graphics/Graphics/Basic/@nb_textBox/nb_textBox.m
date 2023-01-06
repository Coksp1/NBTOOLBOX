classdef nb_textBox < nb_textAnnotation & nb_movableAnnotation & nb_lineAnnotation
% Superclasses:
% 
% nb_textAnnotation, nb_movableAnnotation, nb_lineAnnotation, 
% nb_annotation, handle
%     
% Description:
%     
% A class for adding a text box to a plot.
%     
% Constructor:
%     
%     obj = nb_textBox(varargin)
%     
%     Input:
% 
%     Optional input ('propertyName', propertyValue):
%
%     > You can set some properties of the class. See the list 
%       below. 
%     
%     Output
% 
%     - obj      : An object of class nb_textBox
%     
%     Examples:
% 
% See also:
% nb_textAnnotation, nb_lineAnnotation, nb_annotation, handle,  
% nb_graph_ts, nb_graph_cs, nb_graph_data
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
        
        % Color of text background rectangle. Must be of size; 
        % 1x3. With the RGB colors. Or a string with the name of 
        % the color. See the method interpretColor of the
        % nb_plotHandle class for more on the supported color names.
        % Can also be set to 'none'.
        backgroundColor     = 'none';
                
        % Color of text. Must be of size; 1x3. With the RGB colors.
        % Or a string with the name of the color. See the method 
        % interpretColor of the nb_plotHandle class for more on the
        % supported color names.
        color               = [0 0 0];
        
        % Color of edge of text rectangle. Must be  of size; 1x3. 
        % With the RGB colors. Or a string with the name of the 
        % color. See the method interpretColor of the nb_plotHandle 
        % class for more on the supported color names. Can also be 
        % set to 'none'.
        edgeColor           = 'none';
        
        % {'normal'} | 'italic' | 'oblique'
        fontAngle           = 'normal';
         
        % Horizontal alignment of text. Specifies the horizontal 
        % justification of the text string. Must be a string. 
        % {'left'} | 'center' | 'right'.
        horizontalAlignment = 'left';
        
        % Interpret TeX instructions. Must be a string.
        % 'latex' | {'tex'} | 'none'.
        interpreter         = 'tex';
        
        % The line style of the plotted box. Must be a string.
        % {'-'} | '--' | ':' | '-.' | 'none'. '---' is not 
        % supported.                                    
        lineStyle           = '-'; 
        
        % Width of text rectangle edge. Must be a scalar. Default 
        % is 0.5.
        lineWidth           = 0.5;          
       
        % Space around text. A value in pixels that defines 
        % the space around the text string, but within the 
        % rectangle. Default value is 5 pixels.
        margin              = 5;
        
        % Text orientation. Determines the orientation of the text
        % string. Specify values of rotation in degrees (positive 
        % angles cause counterclockwise rotation). Must be a scalar.
        % Default is 0.
        rotation            = 0;
        
        % The axes to plot against. 'left' or 'right'. 'left' 
        % is default.
        side                = 'left';
        
        % Sets the text of the textbox. Must be a char. Each 
        % vertical element of the given char will result in
        % a new line of text.
        string              = '';

        % The coordinates system to plot in. {'data'} : 
        % xy-coordinates. 'normalized' : Axes are normalized to have 
        % length 1.
        units               = 'data';
        
        % Vertical alignment of text. Specifies the vertical 
        % justification of the text string. Must be a string.
        % 'top' | 'cap' | {'middle'} | 'baseline' | 'bottom'.
        verticalAlignment   = 'middle';
        
        % The x-axis data. As a scalar.
        xData               = [];
        
        % The y-axis data. As a scalar.
        yData               = [];            
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods

        function obj = nb_textBox(varargin)
        % Constructor
        
            if nargin > 0
                
                set(obj,varargin);
                
            end
                 
        end
        
        varargout = set(varargin)
        
%         function set.backgroundColor(obj,value)
%             if ~nb_isColorProp(value)
%                    error([mfilename ':: The backgroundColor property must'...
%                                  ' must have dimension size'...
%                                  ' size(plotData,2) x 3 with the RGB'...
%                                  ' colors or a cellstr with size 1 x'...
%                                  ' size(yData,2) with the color names.'])
%             end
%             obj.backgroundColor = value;
%         end        
% 
%         function set.color(obj,value)
%             if ~nb_isColorProp(value)
%                 error([mfilename ':: The color property must'...
%                                  ' must have dimension size'...
%                                  ' size(plotData,2) x 3 with the RGB'...
%                                  ' colors or a cellstr with size 1 x'...
%                                  ' size(yData,2) with the color names.'])
%             end
%             obj.color = value;
%         end          
%         
%         function set.edgeColor(obj,value)
%             if ~nb_isColorProp(value)
%                 error([mfilename ':: The edgeColor property must'...
%                                  ' must have dimension size'...
%                                  ' size(plotData,2) x 3 with the RGB'...
%                                  ' colors or a cellstr with size 1 x'...
%                                  ' size(yData,2) with the color names.'])
%             end
%             obj.edgeColor = value;
%         end 
%         
%         function set.fontAngle(obj,value)
%             if ~any(strcmp({'normal','italic','oblique'},value))
%                 error([mfilename ':: The fontAngle property must be ',...
%                        'set to either ''normal'',''italic'' or ''oblique''.'])
%             end
%             obj.fontAngle = value;
%         end               
%         
%         function set.horizontalAlignment(obj,value)
%             if ~any(strcmp({'left','center','right'},value))
%                 error([mfilename ':: The fontAngle property must be ',...
%                        'set to either ''left'',''center'' or ''right''.'])
%             end
%             obj.horizontalAlignment = value;
%         end                       
%         
%         function set.interpreter(obj,value)
%             if ~any(strcmp({'tex','none'},value))
%                 error([mfilename ':: The interpreter property must be ',...
%                        'set to either ''latex'',''tex'' or ''none''.'])
%             end
%             obj.interpreter = value;
%         end              
%         
%         function set.lineStyle(obj,value)
%             if ~nb_islineStyle(value)
%                 error([mfilename ':: The lineStyle property must be ',...
%                        'set to a valid line style.'])
%             end
%             obj.lineStyle = value;
%         end               
%         
%         function set.lineWidth(obj,value)
%             if ~nb_islineStyle(value)
%                 error([mfilename ':: The lineWidth property must be ',...
%                        'set to a valid line style.'])
%             end
%             obj.lineWidth = value;
%         end 
        
        function lineWidth = get.lineWidth(obj)
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
        end
        
        function update(obj)

            plot(obj);

        end
        
    end
    
    methods (Access=public,Hidden=true)
        
        function s = struct(obj)
            
            obj.returnNonScaled = true;
            
            s = struct(...
                'backgroundColor',      obj.backgroundColor,...
                'class',                'nb_textBox',...
                'color',                obj.color,...
                'edgeColor',            obj.edgeColor,...
                'fontAngle',            obj.fontAngle,...
                'horizontalAlignment',  obj.horizontalAlignment,...
                'interpreter',          obj.interpreter,...
                'lineStyle',            obj.lineStyle,...
                'lineWidth',            obj.lineWidth,...
                'margin',               obj.margin,...
                'rotation',             obj.rotation,...
                'side',                 obj.side,...
                'string',               obj.string,...
                'units',                obj.units,...
                'verticalAlignment',    obj.verticalAlignment,...
                'xData',                obj.xData,...
                'yData',                obj.yData,...
                'fontName',             obj.fontName,...
                'fontSize',             obj.fontSize,...
                'fontUnits',            obj.fontUnits,...
                'fontWeight',           obj.fontWeight,...
                'normalized',           obj.normalized,...
                'deleteOption',         obj.deleteOption);
            
            obj.returnNonScaled = false;
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        function plot(obj)
            
            % Get the parent to plot on
            %------------------------------------------------------
            ax = obj.parent;
            if isempty(ax)
                return
            end
            if ~isvalid(ax) 
                return
            end
            
            if isempty(obj.xData) || isempty(obj.yData)
                warning([mfilename ':: You must provide the properties ''xData'' and ''yData''. No line is plotted!'])

                % Delete the old object plotted by this object
                %--------------------------------------------------
                obj.deleteChildren();
                return
            end
            
            % Delete the old object plotted by this object
            obj.deleteChildren();

            % Test the color specification
            %--------------------------------------------------------------
            if ischar(obj.color)
                cData = nb_plotHandle.interpretColor(obj.color);
            else
                cData = obj.color;
            end

            if ischar(obj.backgroundColor)
                if ~strcmpi(obj.backgroundColor,'none')
                    textBCData = nb_plotHandle.interpretColor(obj.backgroundColor);
                else
                    textBCData = obj.backgroundColor;
                end
            else
                textBCData = obj.backgroundColor;
            end

            if ischar(obj.edgeColor)
                if ~strcmpi(obj.edgeColor,'none')
                    textECData = nb_plotHandle.interpretColor(obj.edgeColor);
                else
                    textECData = obj.edgeColor;
                end
            else
                textECData = obj.edgeColor;
            end

            % Decide the axes to plot against
            %--------------------------------------------------------------      
            axh = ax.axesLabelHandle; 
            
            % Get the coordinates
            %--------------------------------------------------------------
            posX = get(axh,'xLim');
            posY = get(axh,'yLim');
            pos  = [posX(1),posY(1),posX(2)-posX(1),posY(2)-posY(1)];
            switch lower(obj.units)

                case 'data' 

                    % Find the text location in normalized units
                    %------------------------------------------------------
                    xx  = obj.xData;
                    xx = nb_pos2pos(xx,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');

                    if strcmpi(obj.side,'right')
                        yy  = obj.yData;
                        yy = nb_pos2pos(yy,ax.yLimRight,[pos(2),pos(2) + pos(4)],ax.yScaleRight,'normal');
                    else
                        yy  = obj.yData;
                        yy = nb_pos2pos(yy,ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                    end

                case 'normalized'

                    xx = obj.xData;
                    xx = pos(1) + xx*pos(3);
                    yy = obj.yData;  
                    yy = pos(2) + yy*pos(4);

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end

            % If the font size is normalized we get the font size
            % transformed to another units
            %--------------------------------------------------------------
            if strcmpi(obj.fontUnits,'normalized')

                if strcmpi(obj.normalized,'axes')
                    fontS = obj.fontSize;
                else % figure
                    fontS = obj.fontSize*0.8/ax.position(4);
                end

            else
                fontS = obj.fontSize;
            end
            fontU = obj.fontUnits;

            % Do the plotting
            %--------------------------------------------------------------
            t = text(xx,yy,obj.string,...
                     'backgroundColor',        textBCData,...
                     'color',                  cData,...
                     'edgeColor',              textECData,...
                     'fontAngle',              obj.fontAngle,...
                     'fontName',               obj.fontName,...
                     'fontWeight',             obj.fontWeight,...
                     'fontUnits',              fontU,...
                     'fontSize',               fontS,...
                     'horizontalAlignment',    obj.horizontalAlignment,...
                     'interpreter',            obj.interpreter,...
                     'lineStyle',              obj.lineStyle,...
                     'lineWidth',              obj.lineWidth,...
                     'margin',                 obj.margin,...
                     'parent',                 axh,...
                     'rotation',               obj.rotation,...
                     'verticalAlignment',      obj.verticalAlignment);                          

             % Add a uicontext menu to the text box 
             %-------------------------------------------------------------
             cMenu = uicontextmenu('parent',ax.parent.figureHandle); 
                     uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                     if obj.copyOption
                     uimenu(cMenu,'Label','Copy','Callback',@obj.copyCallback);
                     end
                     uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
             set(t,'UIContextMenu',cMenu)

             % Collect the children
             %-------------------------------------------------------------
             obj.children = [t,cMenu];
             
            % Add listener to the current position of the mouse.
            %------------------------------------------------------
            obj.listeners = [...
                addlistener(obj.parent.parent,'mouseMove', @obj.mouseMoveCallback), ...
                addlistener(obj.parent.parent,'mouseDown', @obj.mouseDownCallback), ...
                addlistener(obj.parent.parent,'mouseUp', @obj.mouseUpCallback)];
            
        end
        
        function mouseMoveCallback(obj, varargin)
        % When the mouse moves on the figure this method will
        % be called by the nb_figure parent.
        
            if ~isvalid(obj)
                return
            end

            if ~ishandle(obj.children) 
                return
            end

            pointer = [];

            if obj.selected
                pointer = obj.pointer;
            else       
                [cPoint,~] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                xx           = cPoint(1);
                yy           = cPoint(2);
                pos          = get(obj.children(1),'extent');

                if xx > pos(1) && xx < pos(1) + pos(3) ...
                   && yy > pos(2) && yy < pos(2) + pos(4) 

                    pointer = 'hand';
                end
            end
            
            % Assign object the selected pointer
            obj.pointer = pointer;
            if ~isempty(obj.pointer)
                set(obj.parent.parent.figureHandle, 'pointer', obj.pointer);
            end
            
        end
        
        function mouseDownCallback(obj, varargin)
            
            if ~isvalid(obj)
                return
            end
            
            if isempty(obj.pointer)
                return
            end
            
            % What to do
            fig = obj.parent.parent.figureHandle;
            switch get(fig, 'SelectionType')
                case 'normal'
                    [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                    obj.startPoint    = [cPoint;cAxPoint];
                    obj.selected      = 1;
            end
            
        end
        
        function mouseUpCallback(obj, varargin)
        % Button release callback function (Used when the text box
        % is moved) 
        %
        % obj     : An object of class nb_textBox
        % hObject : A figure handle
        % event   : MATLAB graph handle event
        
            if ~isvalid(obj)
                return
            end
            
            if ~obj.selected
                return
            end
        
            % Get the new location
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
            % Update the MATLAB text handle
            %------------------------------------------------------
            textH  = obj.children(1);
            pos    = get(textH,'position');
            pos(1) = pos(1) + cPoint(1) - obj.startPoint(1,1);
            pos(2) = pos(2) + cPoint(2) - obj.startPoint(1,2);
            
            % Update the location
            set(textH,'position',pos)
            
            % Deselect the text handle
            set(textH,'selected','off');
            
            % Update the nb_textBox object
            %------------------------------------------------------
            ax = obj.parent;
            
            % Get the coordinates
            switch lower(obj.units)

                case 'data' 

                    newX = nb_pos2pos(cAxPoint(1),[0,1],ax.xLim,'normal',ax.xScale);
                    if strcmpi(obj,'right')
                        newY = nb_pos2pos(cAxPoint(2),[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                    else
                        newY = nb_pos2pos(cAxPoint(2),[0,1],ax.yLim,'normal',ax.yScale);
                    end
                    
                    sX = nb_pos2pos(obj.startPoint(2,1),[0,1],ax.xLim,'normal',ax.xScale);
                    if strcmpi(obj,'right')
                        sY = nb_pos2pos(obj.startPoint(2,2),[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                    else
                        sY = nb_pos2pos(obj.startPoint(2,2),[0,1],ax.yLim,'normal',ax.yScale);
                    end

                case 'normalized'

                    newX = cAxPoint(1);
                    newY = cAxPoint(2);
                    sX   = obj.startPoint(2,1);
                    sY   = obj.startPoint(2,2);
                    
            end
            
            obj.xData = obj.xData + newX - sX;
            obj.yData = obj.yData + newY - sY;
            
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the text
        % handle
            
            nb_editTextBox(obj);
        
        end
        
        function deleteCallback(obj,~,~)
        % Callback function called when user click on the delete 
        % option of the uicontextmenu handle attached to the text
        % handle 
        
            nb_confirmWindow('Are you sure you want to delete the selected object?',@notDelete,{@deleteAnnotation,obj},'Delete Annotation');
            
            function deleteAnnotation(hObject,~,obj)
        
                obj.deleteOption = 'all';
                delete(obj);
                
                % Close question window
                close(get(hObject,'parent'));
                
            end

            function notDelete(hObject,~)

                % Close question window
                close(get(hObject,'parent'));

            end
  
        end
        
    end
    
    methods (Static=true,Hidden=true)
        
        function obj = unstruct(s)
            
            obj                     = nb_textBox();
            obj.backgroundColor     = s.backgroundColor;
            obj.color               = s.color;
            obj.edgeColor           = s.edgeColor;
            obj.fontAngle           = s.fontAngle;
            obj.horizontalAlignment = s.horizontalAlignment;
            obj.interpreter         = s.interpreter;
            obj.lineStyle           = s.lineStyle;
            obj.lineWidth           = s.lineWidth;
            obj.margin              = s.margin;
            obj.rotation            = s.rotation;
            obj.side                = s.side;
            obj.string              = s.string;
            obj.units               = s.units;
            obj.verticalAlignment   = s.verticalAlignment;
            obj.xData               = s.xData;
            obj.yData               = s.yData;
            obj.fontName            = s.fontName;
            obj.fontSize            = s.fontSize;
            obj.fontUnits           = s.fontUnits;
            obj.fontWeight          = s.fontWeight;
            obj.normalized          = s.normalized;
            obj.deleteOption        = s.deleteOption;
            
        end
        
    end
  
end
