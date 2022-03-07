classdef nb_textArrow < nb_textAnnotation & nb_movableAnnotation & nb_lineAnnotation
% Superclasses:
% 
% nb_lineAnnotation, nb_movableAnnotation, nb_textAnnotation, 
% nb_annotation, handle
%     
% Description:
%     
% A class for adding a arrow with a text box to a plot.
%     
% Constructor:
%     
%     obj = nb_textArrow(varargin)
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
%     - obj      : An object of class nb_textArrow
%     
%     Examples:
% 
% See also:
% nb_textAnnotation, nb_annotation, handle, nb_graph_ts, 
% nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
        
        % The color data of the line plotted. Must be of size;
        % 1x3. With the RGB colors. Or a string with the name of 
        % the color. See the method interpretColor of the 
        % nb_plotHandle class for more on the supported color names.
        color               = [0 0 0];       
        
        % {'normal'} | 'italic' | 'oblique'
        fontAngle           = 'normal';
        
        % Length of first arrowhead. Size in points. As a scalar. 
        % Specify in points.1 point = 1/72 inch. The default value
        % is 8.
        % 
        % The first arrowhead is located at the start defined by 
        % the point xData(1), yData(1).
        headLength          = 8;
        
        % Style of first arrowhead. As a string. Specify this 
        % property as one of the strings from the following table.
        % 
        % > 'none'
        % > 'plain'
        % > 'ellipse'
        % > 'vback1'
        % > 'vback2' (default)
        % > 'vback3'
        % > 'cback1'
        % > 'cback2'
        % > 'cback3'
        % > 'star4'
        % > 'rectangle'
        % > 'diamond'
        % > 'rose'
        % > 'hypocycloid'
        % > 'astroid'
        % > 'deltoid'
        headStyle           = 'vback2';
        
        % Width of first arrowhead. Specify in points.
        % 1 point = 1/72 inch. As a scalar. The default  value is
        % 8.
        % 
        % The arrowhead is located at the start defined by the 
        % point xData(1), yData(1).
        headWidth           = 8;
             
        % Horizontal alignment of text. Specifies the horizontal 
        % justification of the text string. Must be a string.
        % 'left' | 'center' | 'right' | {'default'}. When 'default'  
        % is given this class will try to find the best
        % alignment.
        horizontalAlignment = 'default';
        
        % Interpret TeX instructions. Must be a string. 'latex' |
        % {'tex'} | 'none'.
        interpreter         = 'tex';
        
        % The line style of the plotted data. Must be a string.
        % {'-'} | '--' | ':' | '-.' | 'none'. '---' is not 
        % supported.                                    
        lineStyle           = '-'; 
        
        % The line width of the plotted arrow. As an integer.
        lineWidth           = 1.5;          
       
        % The axes to plot against. 'left' or 'right'. 'left' is
        % default.
        side                = 'left';
        
        % Sets the text of the textbox. Must be a char. Each 
        % vertical element of the given char will result in
        % a new line of text.
        string              = '';
        
        % Color of text background rectangle. Must be of size;
        % 1x3. With the RGB colors. Or a string with the name of 
        % the color. See the  method interpretColor of the  
        % nb_plotHandle class for more on the supported color names.
        % Can also be set to 'none'.
        textBackgroundColor = 'none';
        
        % Color of text. Must be of size; 1 x 3. With the RGB 
        % colors. Or a string with the name of the color. See the 
        % method interpretColor of the nb_plotHandle class 
        % for more on the supported color names.
        textColor           = [0 0 0];
        
        % Color of edge of text rectangle. Must be of size; 1 x 3. 
        % With the RGB colors. Or a string with the name of the 
        % color. See the method interpretColor of the nb_plotHandle 
        % class for more on the supported color names. Can also 
        % be set to 'none'.
        textEdgeColor       = 'none';
        
        % Width of text rectangle edge. Must be a scalar. Default
        % is 0.5.
        textLineWidth       = 0.5;
        
        % Space around text. A value in pixels that defines the
        % space around the text string, but within the rectangle. 
        % Default value is 5 pixels.
        textMargin          = 5;

        % Text orientation. Determines the orientation of the 
        % text string. Specify values of rotation in degrees 
        % (positive angles cause counterclockwise rotation). Must 
        % be a scalar. Default is 0.
        textRotation        = 0;
        
        % The coordinates system to plot in. Either {'data'} : 
        % xy-coordinates | 'normalized' : figure coordinates.
        units               = 'data';
        
        % Vertical alignment of text. Specifies the vertical 
        % justification of the text string. Must be a string. 
        % 'top' | 'cap' | 'middle' | 'baseline' | 'bottom' | 
        % 'default'. When 'default' is given this class will try to 
        % find the best alignment.
        verticalAlignment   = 'default';
        
        % The x-axis data. As a double. E.g: [x_begin, x_end].
        xData               = [];         
        
        % The y-axis data. As a double. E.g: [y_begin, y_end].
        yData               = [];            
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_textArrow(varargin)
        % Constructor
        
            if nargin > 0
                
                set(obj,varargin);
                
            end
                 
        end
        
        varargout = set(varargin)
        
        function headLength = get.headLength(obj)
           headLength = nb_scaleLineWidth(obj,obj.headLength); 
        end
        
        function headWidth = get.headWidth(obj)
           headWidth = nb_scaleLineWidth(obj,obj.headWidth); 
        end
        
        function lineWidth = get.lineWidth(obj)
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
        end
        
        function textLineWidth = get.textLineWidth(obj)
           textLineWidth = nb_scaleLineWidth(obj,obj.textLineWidth); 
        end
        
        function update(obj)

            plot(obj);

        end
        
    end
    
    methods(Access=public,Hidden=true)
        
        function s = struct(obj)
            
            obj.returnNonScaled = true;
            
            s = struct(...
                'class',                'nb_textArrow',...
                'color',                obj.color,...
                'fontAngle',            obj.fontAngle,...
                'headLength',           obj.headLength,...
                'headStyle',            obj.headStyle,...
                'headWidth',            obj.headWidth,...
                'horizontalAlignment',  obj.horizontalAlignment,...
                'interpreter',          obj.interpreter,...
                'lineStyle',            obj.lineStyle,...
                'lineWidth',            obj.lineWidth,...
                'side',                 obj.side,...
                'string',               obj.string,...
                'textBackgroundColor',  obj.textBackgroundColor,...
                'textColor',            obj.textColor,...
                'textEdgeColor',        obj.textEdgeColor,...
                'textLineWidth',        obj.textLineWidth,...
                'textMargin',           obj.textMargin,...
                'textRotation',         obj.textRotation,...
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
    
    methods (Access=protected)
        
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
                %----------------------------------------------------------
                obj.deleteChildren();
                return
            end

            % Delete the old object plotted by this object
            %--------------------------------------------------------------
            obj.deleteChildren();

            % Test the color specification
            %--------------------------------------------------------------
            if ischar(obj.color)
                cData = nb_plotHandle.interpretColor(obj.color);
            else
                cData = obj.color;
            end

            if ischar(obj.textColor)
                textCData = nb_plotHandle.interpretColor(obj.textColor);
            else
                textCData = obj.textColor;
            end

            if ischar(obj.textBackgroundColor)
                if ~strcmpi(obj.textBackgroundColor,'none')
                    textBCData = nb_plotHandle.interpretColor(obj.textBackgroundColor);
                else
                    textBCData = obj.textBackgroundColor;
                end
            else
                textBCData = obj.textBackgroundColor;
            end

            if ischar(obj.textEdgeColor)
                if ~strcmpi(obj.textEdgeColor,'none')
                    textECData = nb_plotHandle.interpretColor(obj.textEdgeColor);
                else
                    textECData = obj.textEdgeColor;
                end
            else
                textECData = obj.textEdgeColor;
            end

            % Get the coordinates
            %--------------------------------------------------------------
            pos = ax.position;
            switch lower(obj.units)

                case 'data' 

                    % Find the text location in normalized units
                    %------------------------------------------------------
                    xx = obj.xData;
                    xx = nb_pos2pos(xx,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');

                    if strcmpi(obj.side,'right')
                        yy = obj.yData;
                        yy = nb_pos2pos(yy,ax.yLimRight,[pos(2),pos(2) + pos(4)],ax.yScaleRight,'normal');
                    else
                        yy = obj.yData;
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

            if not(size(xx,1) == 1 && size(xx,2) == 2)
                error([mfilename ':: The xData property should be of size 1 x 2.'])
            end

            if not(size(yy,1) == 1 && size(yy,2) == 2)
                error([mfilename ':: The yData property should be of size 1 x 2.'])
            end

            % Do the plotting
            %--------------------------------------------------------------
            if verLessThan('matlab','8.4')
                fig = ax.parent.figureHandle;
            else
                if isa(ax.parent,'nb_graphPanel')
                    fig = ax.parent.panelHandle;
                else
                    fig = ax.parent.figureHandle;
                end
            end
            
            ann = annotation(fig,          'arrow',...
                             'color',      cData,...
                             'headLength', obj.headLength,...
                             'headStyle',  obj.headStyle,...
                             'headWidth',  obj.headWidth,...
                             'lineStyle',  obj.lineStyle,...
                             'lineWidth',  obj.lineWidth,...
                             'x',          xx,...
                             'y',          yy);

            % Decide the axes to plot against
            %--------------------------------------------------------------      
            axh = ax.axesLabelHandle;  

            % Find the text alignment
            %--------------------------------------------------------------
            [horAlign,verAlign] = nb_textArrow.textAlignment(obj.horizontalAlignment,obj.verticalAlignment,xx,yy);

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
            t = text(xx(1),yy(1),obj.string,...
                     'backgroundColor',        textBCData,...
                     'color',                  textCData,...
                     'edgeColor',              textECData,...
                     'fontAngle',              obj.fontAngle,...
                     'fontName',               obj.fontName,...
                     'fontWeight',             obj.fontWeight,...
                     'fontUnits',              fontU,...
                     'fontSize',               fontS,...
                     'horizontalAlignment',    horAlign,...
                     'interpreter',            obj.interpreter,...
                     'lineWidth',              obj.textLineWidth,...
                     'margin',                 obj.textMargin,...
                     'parent',                 axh,...
                     'rotation',               obj.textRotation,...
                     'verticalAlignment',      verAlign);

             % Collect the children
             %-------------------------------------------------------------
             obj.children = [ann,t];

             % Add a uicontext menu to the text arrow 
             %-------------------------------------------------------------
             cMenu = uicontextmenu('parent',ax.parent.figureHandle); 
                  uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                  if obj.copyOption
                  uimenu(cMenu,'Label','Copy','Callback',@obj.copyCallback);
                  end
                  uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
             set(obj.children,'UIContextMenu',cMenu)         

             % Add listener to the current position of the mouse.
             %-------------------------------------------------------------
             obj.listeners = [addlistener(obj.parent.parent,'mouseMove',@obj.mouseMoveCallback), ...
                 addlistener(obj.parent.parent,'mouseDown',@obj.mouseDownCallback), ...
                 addlistener(obj.parent.parent,'mouseUp',@obj.mouseUpCallback)];

        end
        
        function [xx,yy] = objectPos2axesPos(obj)
            
            ax = obj.parent;
            switch lower(obj.units)
        
                case 'data' 

                    % Find the rectangle location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(obj.xData,ax.xLim,[0,1],ax.xScale,'normal');
                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(obj.yData,ax.yLimRight,[0,1],ax.yScaleRight,'normal');
                    else
                        yy = nb_pos2pos(obj.yData,ax.yLim,[0,1],ax.yScale,'normal');
                    end
                    
                case 'normalized'

                    xx = obj.xData;
                    yy = obj.yData;

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end
            
        end
        
        function mouseMoveCallback(obj, ~, ~)
        
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
            
                [~,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                [xPos,yPos]  = objectPos2axesPos(obj);

                % Get the selection resize position
                %------------------------------------------------------
                x = [xPos(1);
                     xPos(2)];

                y = [yPos(1);
                     yPos(2)];

                % Check if the user have selected one of the resize
                % positions
                %------------------------------------------------------
                xx = cAxPoint(1);
                yy = cAxPoint(2);

                % Assign callback
                %------------------------------------------------------
                tol      = obj.tolerance;
                distance = sqrt((x - xx).^2 + (y - yy).^2);
                ind      = find(distance < tol,1);
                if isempty(ind)

                    % Check if the mouse painter should indicate that
                    % the object can be moved
                    incrx = diff(xPos)/100;
                    if incrx == 0
                        x = repmat(xPos(1),1,100);
                    else
                        x = xPos(1):incrx:xPos(2);
                    end

                    incry = diff(yPos)/100;
                    if incry == 0
                        y = repmat(yPos(1),1,100);
                    else
                        y = yPos(1):incry:yPos(2);
                    end

                    distance = sqrt((x(1:100) - xx).^2 + (y(1:100) - yy).^2);
                    ind      = find(distance < tol,1);
                    if isempty(ind)
                        obj.selectionType = 'none';
                    else

                        pointer = 'hand';

                        % We also set the type of selction
                        obj.selectionType = 'move';

                    end

                else

                    pointer = 'fleur';

                    % We also set the type of selction
                    if ind(1) == 1
                        obj.selectionType = 'start';
                    else
                        obj.selectionType = 'end';
                    end

                end
            end
            
            obj.pointer = pointer;          
            if ~isempty(obj.pointer)
                set(obj.parent.parent.figureHandle, 'pointer', obj.pointer);
            end
            
        end
        
        function mouseDownCallback(obj,~,~)
            
            if ~isvalid(obj)
                return
            end
        
            % Get figue handle
            fig     = obj.parent.parent.figureHandle;
            
            % What to do
            sel_typ = get(fig,'SelectionType');
            switch sel_typ
                case 'normal'
                    
                    switch obj.selectionType
                        
                        case 'start'
                            obj.selected = 1;
                        case 'end'
                            obj.selected = 1;
                        case 'move'
                            obj.selected = 1;
                            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                            obj.startPoint    = [cPoint;cAxPoint];
                        otherwise
                            obj.selected = 0;
                            
                    end
            end
            
        end
        
        function mouseUpCallback(obj, ~, ~)
            
            if ~isvalid(obj)
                return
            end
            
            if ~obj.selected
                return
            end
              
            switch obj.selectionType
                case 'start'
                    obj.startMove();
                case 'end'
                    obj.endMove();
                case 'move'
                    obj.move();
            end
            
            obj.selected = 0;
            
        end
        
        function startMove(obj,~,~)
        % Resize the rectangle left side   
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
            % Update the annotation arrow
            %------------------------------------------------------
            ann  = obj.children(1);
            x    = get(ann,'x');
            x(1) = cPoint(1);
            y    = get(ann,'y');
            y(1) = cPoint(2);
            set(ann,'x',x,'y',y);
            
            % Update the text box
            %------------------------------------------------------
            [horAlign,verAlign] = nb_textArrow.textAlignment(obj.horizontalAlignment,obj.verticalAlignment,x,y);
            
            t = obj.children(2);
            set(t,'position',               [x(1),y(1)],...
                  'horizontalAlignment',    horAlign,...
                  'verticalAlignment',      verAlign);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
            switch lower(obj.units)

                case 'data' 

                    newX = nb_pos2pos(cAxPoint(1),[0,1],ax.xLim,'normal',ax.xScale);
                    if strcmpi(obj,'right')
                        newY = nb_pos2pos(cAxPoint(2),[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                    else
                        newY = nb_pos2pos(cAxPoint(2),[0,1],ax.yLim,'normal',ax.yScale);
                    end
                    
                case 'normalized'

                    newX = cAxPoint(1); 
                    newY = cAxPoint(2);
                    
            end
            
            obj.xData(1) = newX;
            obj.yData(1) = newY;
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function endMove(obj,~,~)
        % Resize the rectangle left side   
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
            % Update the arrow
            %------------------------------------------------------
            ann  = obj.children(1);
            x    = get(ann,'x');
            x(2) = cPoint(1);
            y    = get(ann,'y');
            y(2) = cPoint(2);
            set(ann,'x',x,'y',y);
            
            % Update the text box
            %------------------------------------------------------
            [horAlign,verAlign] = nb_textArrow.textAlignment(obj.horizontalAlignment,obj.verticalAlignment,x,y);
            
            t = obj.children(2);
            set(t,'horizontalAlignment',    horAlign,...
                  'verticalAlignment',      verAlign);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
            switch lower(obj.units)

                case 'data' 

                    newX = nb_pos2pos(cAxPoint(1),[0,1],ax.xLim,'normal',ax.xScale);
                    if strcmpi(obj,'right')
                        newY = nb_pos2pos(cAxPoint(2),[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                    else
                        newY = nb_pos2pos(cAxPoint(2),[0,1],ax.yLim,'normal',ax.yScale);
                    end
                    
                case 'normalized'

                    newX = cAxPoint(1); 
                    newY = cAxPoint(2);
                    
            end
            
            obj.xData(2) = newX;
            obj.yData(2) = newY;
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function move(obj,~,~)
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
            % Update the arrow
            %------------------------------------------------------
            ann = obj.children(1);
            x   = get(ann,'x');
            x   = x + cPoint(1) - obj.startPoint(1,1);
            y   = get(ann,'y');
            y   = y + cPoint(2) - obj.startPoint(1,2);
            set(ann,'x',x,'y',y);
            
            % Update the text box
            %------------------------------------------------------
            t = obj.children(2);
            set(t,'position',[x(1),y(1)]);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
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
            
            obj.xData    = obj.xData + newX - sX;
            obj.yData    = obj.yData + newY - sY;
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the
        % annotation handle
            
            nb_editTextArrow(obj);
        
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
    
    methods (Static=true)
        
        function [horAlign,verAlign] = textAlignment(horAlign,verAlign,xx,yy)
        % Get the text alignment of the text handle. 
        %
        % xx : A 1x2 double with th x-axis figure position of the
        %      arrow annotation
        %
        % yy : A 1x2 double with th y-axis figure position of the
        %      arrow annotation
        
            dx        = diff(xx);
            dy        = diff(yy);
            [theta,~] = cart2pol(dx,dy);

            if 0 > theta
                theta = theta + 2*pi;
            elseif theta > 2*pi
                theta = theta - 2*pi;
            end

            if strcmpi(horAlign,'default')

                if (pi/4 < theta && theta < 3*pi/4) || (5*pi/4 < theta && theta < 7*pi/4)
                    horAlign = 'center';
                elseif 3*pi/4 <= theta && theta <= 5*pi/4
                    horAlign = 'left';
                elseif (7*pi/4 <= theta && theta <= 2*pi) || (0 <= theta && theta <= pi/4)
                    horAlign = 'right';
                end

            end

            if strcmpi(verAlign,'default')

                if (pi/4 < theta && theta < 3*pi/4) 
                    verAlign = 'top';
                elseif (5*pi/4 < theta && theta < 7*pi/4)
                    verAlign = 'bottom';
                elseif (7*pi/4 <= theta && theta <= 2*pi) || (0 <= theta && theta <= pi/4) || (3*pi/4 <= theta && theta <= 5*pi/4)
                    verAlign = 'middle';
                end

            end
            
        end
        
    end
    
    methods (Static=true,Hidden=true)
        
        function obj = unstruct(s)
            
            obj                     = nb_textArrow();
            obj.color               = s.color;
            obj.fontAngle           = s.fontAngle;
            obj.headLength          = s.headLength;
            obj.headStyle           = s.headStyle;
            obj.headWidth           = s.headWidth;
            obj.horizontalAlignment = s.horizontalAlignment;
            obj.interpreter         = s.interpreter;
            obj.lineStyle           = s.lineStyle;
            obj.lineWidth           = s.lineWidth;
            obj.side                = s.side;
            obj.string              = s.string;
            obj.textBackgroundColor = s.textBackgroundColor;
            obj.textColor           = s.textColor;
            obj.textEdgeColor       = s.textEdgeColor;
            obj.textLineWidth       = s.textLineWidth;
            obj.textMargin          = s.textMargin;
            obj.textRotation        = s.textRotation;
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
