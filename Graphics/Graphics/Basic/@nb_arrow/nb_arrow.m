classdef nb_arrow < nb_annotation & nb_movableAnnotation & nb_lineAnnotation
% Superclasses:
% 
% nb_lineAnnotation, nb_movableAnnotation, nb_annotation, handle
%     
% Description:
%     
% A class for adding arrows to a plot.
%     
% Constructor:
%     
%     obj = nb_arrow(varargin)
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
%     - obj      : An object of class nb_arrow
%     
%     Examples:
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
        
        % The color data of the line plotted. Must be of size;
        % 1 x 3. With the RGB colors. Or a string with the
        % name of the color. See the method interpretColor
        % of the nb_plotHandle class for more on the supported
        % color names.
        color               = [0 0 0]; 
        
        % Length of first arrowhead. Size in points. As a scalar.
        % Specify in points.1 point = 1/72 inch. The default
        % value is 8.
        % 
        % The first arrowhead is located at the start defined by 
        % the point xData(1), yData(1).
        head1Length         = 8;
        
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
        head1Style          = 'none';
        
        % Width of first arrowhead. Specify in points.
        % 1 point = 1/72 inch. As a scalar. The default value is
        % 8.
        % 
        % The first arrowhead is located at the start defined by
        % the point xData(1), yData(1).
        head1Width          = 8;
        
        % Length of second arrowhead. Size in points. As a scalar. 
        % Specify in points.1 point =  1/72 inch. The default value 
        % is 10.
        % 
        % The second arrowhead is located at the end defined by
        % the point xData(2), yData(2).
        head2Length         = 8;
        
        % Style of second arrowhead. As a string. Specify this 
        % property as one of the strings from the following table.
        % 
        % > 'none' (default)
        % > 'plain'
        % > 'ellipse'
        % > 'vback1'
        % > 'vback2' 
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
        head2Style          = 'vback2';
        
        % Width of second arrowhead. Specify in points.
        % 1 point = 1/72 inch. As a scalar. The default value is 
        % 10.
        % 
        % The second arrowhead is located at the end defined by
        % the point xData(2), yData(2).
        head2Width          = 8;
                             
        % The line style of the plotted data. Must be a string.
        % {'-'} | '--' | ':' | '-.' | 'none'. '---' is not supported.                                    
        lineStyle           = '-'; 
        
        % The line width of the plotted arrow. As an integer.
        lineWidth           = 1.5;          
       
        % The axes to plot against. 'left' or 'right'. 'left' is
        % default.
        side                = 'left';
        
        % The coordinates system to plot in. Either {'data'} : 
        % xy-coordinates | 'normalized' : figure coordinates.
        units               = 'data'; 
        
        % The x-axis data. As a 1x2 double. E.g: [x_begin, x_end].
        xData               = [];  
        
        % The y-axis data. As a 1x2 double. E.g: [y_begin, y_end].                     
        yData               = [];  
        
        ID
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_arrow(varargin)
        % Constructor
        
            if nargin > 0
                
                set(obj,varargin);
                
            end
            
            obj.ID = java.rmi.server.UID();
                 
        end
        
        varargout = set(varargin)
        
        function head1Length = get.head1Length(obj)
           head1Length = nb_scaleLineWidth(obj,obj.head1Length); 
        end
        
        function head1Width = get.head1Width(obj)
           head1Width = nb_scaleLineWidth(obj,obj.head1Width); 
        end
        
        function head2Length = get.head2Length(obj)
           head2Length = nb_scaleLineWidth(obj,obj.head2Length); 
        end
        
        function head2Width = get.head2Width(obj)
           head2Width = nb_scaleLineWidth(obj,obj.head2Width); 
        end
        
        function lineWidth = get.lineWidth(obj)
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
        end
        
        function update(obj)

            plot(obj);

        end
          
    end
    
    methods(Access=public,Hidden=true)
        
        function s = struct(obj)
            
            obj.returnNonScaled = true;
            
            s = struct(...
                'class',        'nb_arrow',...
                'color',        obj.color,...
                'head1Length',  obj.head1Length,...
                'head1Style',   obj.head1Style,...
                'head1Width',   obj.head1Width,...
                'head2Length',  obj.head2Length,...
                'head2Style',   obj.head2Style,...
                'head2Width',   obj.head2Width,...
                'lineStyle',    obj.lineStyle,...
                'lineWidth',    obj.lineWidth,...
                'side',         obj.side,...
                'units',        obj.units,...
                'xData',        obj.xData,...
                'yData',        obj.yData,...
                'deleteOption', obj.deleteOption);
            
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

            % Test the color spcification
            %------------------------------------------------------
            if ischar(obj.color)
                cData = nb_plotHandle.interpretColor(obj.color);
            else
                cData = obj.color;
            end

            % Get the coordinates
            %------------------------------------------------------
            pos = ax.position;
            switch lower(obj.units)

                case 'data' 

                    % Find the location in normalized units
                    %----------------------------------------------
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

            % Do the plotting
            if nb_oldGraphVersion
                fig = ax.parent.figureHandle;
            else
                if isa(ax.parent,'nb_graphPanel')
                    fig = ax.parent.panelHandle;
                else
                    fig = ax.parent.figureHandle;
                end
            end
            
            obj.children = annotation(fig, 'doublearrow',...
                                      'color',          cData,...
                                      'head1Length',    obj.head1Length,...
                                      'head1Style',     obj.head1Style,...
                                      'head1Width',     obj.head1Width,...
                                      'head2Length',    obj.head2Length,...
                                      'head2Style',     obj.head2Style,...
                                      'head2Width',     obj.head2Width,...
                                      'lineStyle',      obj.lineStyle,...
                                      'lineWidth',      obj.lineWidth,...
                                      'x',              xx,...
                                      'y',              yy);

            % Add a uicontext menu to the arrow
            %------------------------------------------------------
            cMenu = uicontextmenu('parent',ax.parent.figureHandle); 
                 uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                 if obj.copyOption
                 uimenu(cMenu,'Label','Copy','Callback',@obj.copyCallback);
                 end
                 uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
            set(obj.children,'UIContextMenu',cMenu)         

            % Add listener to the current position of the mouse.
            %------------------------------------------------------
            obj.listeners = [...
                addlistener(obj.parent.parent,'mouseMove', @obj.mouseMoveCallback), ...
                addlistener(obj.parent.parent,'mouseDown', @obj.mouseDownCallback), ...
                addlistener(obj.parent.parent,'mouseUp', @obj.mouseUpCallback)];
            
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
            
            % What to do
            fig = obj.parent.parent.figureHandle;
            switch get(fig, 'SelectionType')
                case 'normal'
                    
                    switch obj.selectionType
                        
                        case {'start', 'end'}
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
        % Move start of arrow  
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
            % Update the children
            %------------------------------------------------------
            x    = get(obj.children,'x');
            x(1) = cPoint(1);
            y    = get(obj.children,'y');
            y(1) = cPoint(2);
            set(obj.children,'x',x,'y',y);
            
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
            
            % Update the children
            % ------------------------------------------------------
            x    = get(obj.children,'x');
            x(2) = cPoint(1);
            y    = get(obj.children,'y');
            y(2) = cPoint(2);
            set(obj.children,'x',x,'y',y);
            
            % Update the object itself.
            % ------------------------------------------------------
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
            
            % Update the children
            %------------------------------------------------------
            x = get(obj.children,'x');
            x = x + cPoint(1) - obj.startPoint(1,1);
            y = get(obj.children,'y');
            y = y + cPoint(2) - obj.startPoint(1,2);
            set(obj.children,'x',x,'y',y);
            
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
            
            nb_editArrow(obj);
        
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
            
            obj                 = nb_arrow();
            obj.color           = s.color;
            obj.head1Length     = s.head1Length;
            obj.head1Style      = s.head1Style;
            obj.head1Width      = s.head1Width;
            obj.head2Length     = s.head2Length;
            obj.head2Style      = s.head2Style;
            obj.head2Width      = s.head2Width;
            obj.lineStyle       = s.lineStyle;
            obj.lineWidth       = s.lineWidth;
            obj.side            = s.side;
            obj.units           = s.units;
            obj.xData           = s.xData;
            obj.yData           = s.yData;
            obj.deleteOption    = s.deleteOption;
            
        end
        
    end
    
end
