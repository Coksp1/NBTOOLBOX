classdef nb_drawCircle < nb_annotation & nb_movableAnnotation & nb_lineAnnotation
% Superclasses:
% 
% nb_lineAnnotation, nb_movableAnnotation, nb_annotation, handle
%     
% Description:
%     
% A class for adding a arbitary circle to a plot using the patch
% handle class.
%     
% Constructor:
%     
%     obj = nb_drawCircle(varargin)
%     
%     Input:
% 
%     Optional input ('propertyName', propertyValue):
%
%     > You can set some properties of the class.
%     
%     Output
% 
%     - obj : An object of class nb_drawPatch
%     
% See also:
% nb_annotation, handle, nb_graph_ts, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
        
        % 'on' or 'off'. Clipping to axes rectangle. When Clipping 
        % is on, MATLAB does not display any portion of the patch 
        % outside the axes rectangle.
        clipping     = 'off'; 
        
        % The color of the edge of the rectangle. In RGB  colors | 
        % 'none' : No edgeLine | 'same' : Same color as the face 
        % color | a string with the color name.
        edgeColor    = 'same'; 
        
        % The RGB color of the face of the rectangle.
        % 
        % Must be a 1 x 3 double with the RGB colors or a string 
        % with the color name. See the  method interpretColor of 
        % the nb_plotHandle class for more on the supported color 
        % names.
        faceColor    = [0 0 0]; 
          
        % The line style of the edge of the patch.
        lineStyle    = '-';       
        
        % The line width of the edge of the patch.
        lineWidth    = 1.5;       
        
        % Radious at the center of the circle in the y-direction.
        % Default is 1.
        rData        = 1;
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default)
        side         = 'left';
        
        % The coordinates system to plot in. Either {'data'} : 
        % xy-coordinates | 'normalized' : figure coordinates.
        units        = 'data'; 
        
        % The x-axis data. As a 1x2 double. E.g: [x_begin, x_end].
        xData        = [];  
        
        % The y-axis data. As a 1x2 double. E.g: [y_begin, y_end].                     
        yData        = [];  
          
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_drawCircle(varargin)
        % Constructor
        
            if nargin > 0 
                set(obj,varargin);
            end
                 
        end
        
        varargout = set(varargin)
        
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
               'class',         'nb_drawCircle',...
               'clipping',      obj.clipping,...
               'edgeColor',     obj.edgeColor,...
               'faceColor',     obj.faceColor,...
               'lineStyle',     obj.lineStyle,...
               'lineWidth',     obj.lineWidth,...
               'position',      obj.position,...
               'rData',         obj.xData,...
               'side',          obj.side,...
               'units',         obj.units,...
               'xData',         obj.xData,...
               'yData',         obj.yData,...
               'deleteOption',  obj.deleteOption); 
            
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
                warning([mfilename ':: You must provide the properties ''xData'' and ''yData''. Nothing is plotted!'])

                % Delete the old object plotted by this object
                %----------------------------------------------------------
                obj.deleteChildren();
                return
            end

            % Delete the old object plotted by this object
            %--------------------------------------------------------------
            obj.deleteChildren();

            % Get the coordinates
            %--------------------------------------------------------------
            [xx,yy] = objectPos2childrenPos(obj);

            % Decide the axes to plot against
            %--------------------------------------------------------------      
            axh = ax.axesLabelHandle; 

            % Check some inputs
            %--------------------------------------------------------------
            faceC = interpretFaceColor(obj);
            edgeC = interpretEdgeColor(obj);

            % Do the plotting
            %--------------------------------------------------------------
            p = patch(...
                 'xData',         xx,...
                 'yData',         yy,...
                 'clipping',      obj.clipping,...
                 'edgeColor',     edgeC,...
                 'faceColor',     faceC,...
                 'lineStyle',     obj.lineStyle,...
                 'lineWidth',     obj.lineWidth,...
                 'parent',        axh);

            % Add a uicontext menu to the text box 
            %--------------------------------------------------------------
            cMenu = uicontextmenu('parent',ax.parent.figureHandle); 
                 uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                 if obj.copyOption
                 uimenu(cMenu,'Label','Copy','Callback',@obj.copyCallback);
                 end
                 uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
            set(p,'UIContextMenu',cMenu)         

            % Collect the children
            %--------------------------------------------------------------
            obj.children = p;
            
            % Add listener to the current position of the mouse.
            %------------------------------------------------------
            obj.listeners = [...
                addlistener(obj.parent.parent,'mouseMove', @obj.mouseMoveCallback), ...
                addlistener(obj.parent.parent,'mouseDown', @obj.mouseDownCallback), ...
                addlistener(obj.parent.parent,'mouseUp', @obj.mouseUpCallback)];
            
        end
        
        function mouseMoveCallback(obj, varargin)
        % When the mouse moves on the figure
        
            if ~isvalid(obj)
                return
            end

            if ~ishandle(obj.children) 
                return
            end

            if obj.selected
                pointer = obj.pointer;
            else       
            
                [~,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                
                % Get the selection resize position
                %------------------------------------------------------
                [x,y] = objectPos2axesPosResize(obj);

                % Check if the user have selected one of the resize
                % positions
                %------------------------------------------------------
                xx = cAxPoint(1);
                yy = cAxPoint(2);

                % Assign callback
                %------------------------------------------------------
                tol      = obj.tolerance;
                distance = sqrt((x - xx).^2 + (y - yy).^2);
                ind      = find(distance < tol);
                if isempty(ind)

                    % Get the selection move position
                    [x,y] = objectPos2axesPos(obj);
                    
                    % Check if the mouse pointer should indicate that
                    % the object can be moved
                    distance = sqrt((x - xx).^2 + (y - yy).^2);
                    ind      = find(distance < tol,1);
                    if isempty(ind)
                        pointer = '';
                    else
                        pointer = 'hand';
                    end
                    
                else

                    % Indicate by the mouse pointer that the object
                    % can be resized
                    pointer = 'fleur';
                    
                    % We also set the type of selction
                    if ind(1) == 1
                        obj.selectionType = 'start';
                    else
                        obj.selectionType = 'end';
                    end

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
            
            return
            
            % What to do
            fig = obj.parent.parent.figureHandle;
            switch get(fig, 'SelectionType')
                case 'normal'
                    obj.getSelectionType();
                    obj.selected      = 1;
            end
            
        end
        
        function mouseUpCallback(obj, varargin)
            
            if ~isvalid(obj)
                return
            end
            
            if ~obj.selected
                return
            end
            
            return
            
            switch lower(obj.selectionType)
                case 'move'
                    obj.move();
                case 'left'
                    obj.leftResize();
                case 'right'
                    obj.rightResize();
                case 'top'
                    obj.topResize();
                case 'bottom'
                    obj.bottomResize();
            end
            
        end
        
        function [x,y] = objectPos2childrenPos(obj)
            
            ax  = obj.parent;
            pos = ax.position;
            switch lower(obj.units)
        
                case 'data' 

                    % Find the rectangle location in normalized units
                    xx = nb_pos2pos(obj.xData,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');
                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(obj.yData,ax.yLimRight,[pos(2),pos(2) + pos(4)],ax.yScaleRight,'normal');
                    else
                        yy = nb_pos2pos(obj.yData,ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                    end
                    if strcmpi(obj.side,'right')
                        rr = nb_pos2pos(obj.rData,[0,diff(ax.yLimRight)],[pos(2),pos(2) + pos(4)],ax.yScaleRight,'normal');
                    else
                        rr = nb_pos2pos(obj.rData,[0,diff(ax.yLim)],[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                    end
                    
                case 'normalized'

                    xx = obj.xData;
                    yy = obj.yData;
                    rr = obj.rData;

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end
            
            % Map from radious and diagonal to circle coordinates
            angle  = atand(diff(yy)/diff(xx));
            y0     = mean(yy);
            x0     = mean(xx);
            a      = diff(xx)/2;
            b      = rr;
            theta  = 0:0.01:2*pi;
            r      = a*b./sqrt((b*cos(theta)).^2 + (a*sin(theta)).^2);
            x      = r.*cos(theta);
            y      = r.*sin(theta);
            rotate = [ cosd(angle), -sind(angle);...
                       sind(angle), cosd(angle)];
            xy     = [x; y]';
            xy     = xy * rotate;
            x      = xy(:, 1)';
            y      = xy(:, 2)';
            y      = y + y0; 
            x      = x + x0;
            
        end
        
        
        function [x,y] = objectPos2axesPosResize(obj)
            
            ax  = obj.parent;
            switch lower(obj.units)
        
                case 'data' 

                    % Find the rectangle location in normalized units
                    x = nb_pos2pos(obj.xData,ax.xLim,[0,1],ax.xScale,'normal');
                    if strcmpi(obj.side,'right')
                        y = nb_pos2pos(obj.yData,ax.yLimRight,[0,1],ax.yScaleRight,'normal');
                    else
                        y = nb_pos2pos(obj.yData,ax.yLim,[0,1],ax.yScale,'normal');
                    end
                    
                case 'normalized'

                    x = obj.xData;
                    y = obj.yData;

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end
            
        end
        
        function [x,y] = objectPos2axesPos(obj)
            
            ax = obj.parent;
            switch lower(obj.units)
        
                case 'data' 

                    % Find the rectangle location in normalized units
                    xx = nb_pos2pos(obj.xData,ax.xLim,[0,1],ax.xScale,'normal');
                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(obj.yData,ax.yLimRight,[0,1],ax.yScaleRight,'normal');
                    else
                        yy = nb_pos2pos(obj.yData,ax.yLim,[0,1],ax.yScale,'normal');
                    end
                    if strcmpi(obj.side,'right')
                        rr = nb_pos2pos(obj.rData,[0,diff(ax.yLimRight)],[0,1],ax.yScaleRight,'normal');
                    else
                        rr = nb_pos2pos(obj.rData,[0,diff(ax.yLim)],[0,1],ax.yScale,'normal');
                    end
                    
                case 'normalized'

                    xx = obj.xData;
                    yy = obj.yData;
                    rr = obj.rData;

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end
            
            % Map from radious and diagonal to circle coordinates
            angle  = atand(diff(yy)/diff(xx));
            y0     = mean(yy);
            x0     = mean(xx);
            a      = diff(xx)/2;
            b      = rr;
            theta  = 0:0.01:2*pi;
            r      = a*b./sqrt((b*cos(theta)).^2 + (a*sin(theta)).^2);
            x      = r.*cos(theta);
            y      = r.*sin(theta);
            rotate = [ cosd(angle), sind(angle);...
                      -sind(angle), cosd(angle)];
            xy     = [x; y]';
            xy     = xy * rotate;
            x      = xy(:, 1)';
            y      = xy(:, 2)';
            y      = y + y0; 
            x      = x + x0;
            
        end
        
        function faceC = interpretFaceColor(obj)
        % Interpret the faceColor property
        
            if isempty(obj.faceColor)
                
                % Get the default color
                faceC = [0 0 0];

            elseif isnumeric(obj.faceColor)

                if size(obj.faceColor,2) ~= 3 || size(obj.faceColor,1) ~= 1
                    error([mfilename ':: The ''faceColor'' property must be a 1x3 matrix with the rgb colors of the plotted data.'])
                end
                faceC = obj.faceColor;

            elseif ischar(obj.faceColor)

                if size(obj.faceColor,1) ~= 1
                    error([mfilename ':: The char given by ''faceColor'' property can only have 1 rows. Has: ' int2str(size(obj.cData,1)) '.'])
                else
                    faceC = nb_plotHandle.interpretColor(obj.faceColor);
                end    

            elseif iscell(obj.faceColor)

                if length(obj.faceColor) ~= 1
                    error([mfilename ':: The cellstr array given by ''faceColor'' property can only have length 1. Has: ' int2str(length(obj.cData)) '.'])
                else
                    faceC = nb_plotHandle.interpretColor(obj.faceColor);
                end

            else

                error([mfilename ':: The property ''faceColor'' doesn''t support input of class ' class(obj.faceColor)])    

            end
            
        end
        
        function edgeC = interpretEdgeColor(obj)
        % Interpret the faceColor property
        
            if isempty(obj.edgeColor)
                
                % Get the default color
                edgeC = [0 0 0];

            elseif isnumeric(obj.edgeColor)

                if size(obj.edgeColor,2) ~= 3 || size(obj.edgeColor,1) ~= 1
                    error([mfilename ':: The ''edgeColor'' property must be a 1x3 matrix with the rgb colors of the plotted data.'])
                end
                edgeC = obj.edgeColor;

            elseif ischar(obj.edgeColor)

                if size(obj.edgeColor,1) ~= 1
                    error([mfilename ':: The char given by ''edgeColor'' property can only have 1 rows. Has: ' int2str(size(obj.cData,1)) '.'])
                else
                    if strcmpi(obj.edgeColor,'same')
                        edgeC = interpretFaceColor(obj);
                    else
                        edgeC = nb_plotHandle.interpretColor(obj.edgeColor);
                    end
                end 

            elseif iscell(obj.edgeColor)

                if length(obj.edgeColor) ~= 1
                    error([mfilename ':: The cellstr array given by ''edgeColor'' property can only have length 1. Has: ' int2str(length(obj.cData)) '.'])
                else
                    if strcmpi(obj.edgeColor{1},'same')
                        edgeC = interpretFaceColor(obj);
                    else
                        edgeC = nb_plotHandle.interpretColor(obj.edgeColor);
                    end
                end

            else

                error([mfilename ':: The property ''edgeColor'' doesn''t support input of class ' class(obj.edgeColor)])    

            end
            
        end
        
        function getSelectionType(obj)
        % Get the selection type when the object is selcted by the
        % user. 
        %
        % Either : 'move','left','right','top','bottom'.
            
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            pos               = objectPos2axesPos(obj);
            
            % Get the selection resize position
            %------------------------------------------------------
            x = [pos(1);
                 pos(1) + pos(3);
                 pos(1) + pos(3)/2;
                 pos(1) + pos(3)/2];
                 
            y = [pos(2) + pos(4)/2;
                 pos(2) + pos(4)/2;
                 pos(2) + pos(4);
                 pos(2)];
                    
            % Check if the user have selected one of the resize
            % positions
            %------------------------------------------------------
            xx = cAxPoint(1);
            yy = cAxPoint(2);
            
            % Assign callabck
            %------------------------------------------------------
            %fig      = obj.parent.parent.figureHandle;
            distance = sqrt((x - xx).^2 + (y - yy).^2);
            ind      = find(distance < 0.01);
            if isempty(ind)
                obj.selectionType = 'move';
                obj.startPoint    = [cPoint;cAxPoint];
            else
                ind = ind(1);
                switch ind
                    case 1
                        obj.selectionType = 'left';
                    case 2
                        obj.selectionType = 'right';
                    case 3
                        obj.selectionType = 'top';
                    case 4
                        obj.selectionType = 'bottom';
                end
                
            end
                
        end
        
        
        
        function move(obj)
        % Callback function for moving the rectangle handle
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            xx                = cPoint(1);
            yy                = cPoint(2);
            
            % Update the children
            %------------------------------------------------------
            childrenPos    = get(obj.children,'position');
            childrenPos(1) = childrenPos(1) + xx - obj.startPoint(1,1);
            childrenPos(2) = childrenPos(2) + yy - obj.startPoint(1,2);
            set(obj.children,'position',childrenPos);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
            switch lower(obj.units)

                case 'data' 

                    newPos1 = nb_pos2pos(cAxPoint(1),[0,1],ax.xLim,'normal',ax.xScale);
                    if strcmpi(obj,'right')
                        newPos2 = nb_pos2pos(cAxPoint(2),[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                    else
                        newPos2 = nb_pos2pos(cAxPoint(2),[0,1],ax.yLim,'normal',ax.yScale);
                    end
                    
                    sPos1 = nb_pos2pos(obj.startPoint(2,1),[0,1],ax.xLim,'normal',ax.xScale);
                    if strcmpi(obj,'right')
                        sPos2 = nb_pos2pos(obj.startPoint(2,2),[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                    else
                        sPos2 = nb_pos2pos(obj.startPoint(2,2),[0,1],ax.yLim,'normal',ax.yScale);
                    end
                    
                case 'normalized'

                    newPos1 = cAxPoint(1);
                    newPos2 = cAxPoint(2);
                    sPos1   = obj.startPoint(2,1);
                    sPos2   = obj.startPoint(2,2);
                    
            end
            
            obj.position(1) = obj.position(1) + newPos1 - sPos1;
            obj.position(2) = obj.position(2) + newPos2 - sPos2;
            obj.selected    = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the text
        % handle
            
            return
            nb_editDrawCircle(obj);
        
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
    
    methods(Access=public,Hidden=true,Static=true)
        
        function obj = unstruct(s)
        
            obj                 = nb_drawPatch();
            obj.curvature       = s.curvature;
            obj.clipping        = s.clipping;
            obj.edgeColor       = s.edgeColor;
            obj.faceColor       = s.faceColor;
            obj.lineStyle       = s.lineStyle;
            obj.lineWidth       = s.lineWidth;
            obj.position        = s.position;
            obj.side            = s.side;
            obj.units           = s.units;
            obj.deleteOption    = s.deleteOption;
            
        end
        
    end
     
end
