classdef nb_drawPatch < nb_annotation & nb_movableAnnotation & nb_lineAnnotation
% Superclasses:
% 
% nb_lineAnnotation, nb_movableAnnotation, nb_annotation, handle
%     
% Description:
%     
% A class for adding a arbitary patch to a plot using the rectangle
% handle class.
%     
% Constructor:
%     
%     obj = nb_drawPatch(varargin)
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
%     - obj      : An object of class nb_drawPatch
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
        
        % 'on' or 'off'. Clipping to axes rectangle. When Clipping 
        % is on, MATLAB does not display any portion of the patch 
        % outside the axes rectangle.
        clipping     = 'off'; 
        
        % one- or two-element vector [x,y]. Default is [0,0]
        %
        % Amount of horizontal and vertical curvature. Specifies 
        % the curvature of the rectangle sides, which enables the 
        % shape of the rectangle to vary from rectangular to 
        % ellipsoidal. The horizontal curvature x is the fraction 
        % of width of the rectangle that is curved along the top 
        % and bottom edges. The vertical curvature y is the 
        % fraction of the height of the rectangle that is curved 
        % along the left and right edges.
        % 
        % The values of x and y can range from 0 (no curvature) to 
        % 1 (maximum curvature). A value of [0,0] creates a 
        % rectangle with square sides. A value of [1,1] creates an 
        % ellipse. If you specify only one value for Curvature, 
        % then the same length (in axes data units) is curved along 
        % both horizontal and vertical sides. The amount of 
        % curvature is determined by the shorter dimension
        curvature    = [0 0];
        
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
        
        % The position of the MATLAB rectangle object.
        position     = [0 0 1 1];   
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default)
        side         = 'left';
        
        % The coordinates system to plot in. Either {'data'} : 
        % xy-coordinates | 'normalized' : figure coordinates.
        units        = 'data';       
          
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_drawPatch(varargin)
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
               'class',         'nb_drawPatch',...
               'clipping',      obj.clipping,...
               'curvature',     obj.curvature,...
               'edgeColor',     obj.edgeColor,...
               'faceColor',     obj.faceColor,...
               'lineStyle',     obj.lineStyle,...
               'lineWidth',     obj.lineWidth,...
               'position',      obj.position,...
               'side',          obj.side,...
               'units',         obj.units,...
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
            
            if isempty(obj.position)
                warning([mfilename ':: You must provide the property ''position''. Nothing is plotted!'])

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
            plottedPos = objectPos2childrenPos(obj);

            % Decide the axes to plot against
            %--------------------------------------------------------------      
            axh = ax.axesLabelHandle; 

            % Check some inputs
            %--------------------------------------------------------------
            faceC = interpretFaceColor(obj);
            edgeC = interpretEdgeColor(obj);

            % Do the plotting
            %--------------------------------------------------------------
            p = rectangle(...
                         'clipping',      obj.clipping,...
                         'curvature',     obj.curvature,...
                         'edgeColor',     edgeC,...
                         'faceColor',     faceC,...
                         'lineStyle',     obj.lineStyle,...
                         'lineWidth',     obj.lineWidth,...
                         'parent',        axh,...
                         'position',      plottedPos);

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

            pointer = [];

            if obj.selected
                pointer = obj.pointer;
            else       
            
                [~,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                pos          = objectPos2axesPos(obj);

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

                % Assign callback
                %------------------------------------------------------
                tol      = obj.tolerance;
                distance = sqrt((x - xx).^2 + (y - yy).^2);
                ind      = find(distance < tol);
                if isempty(ind)

                    % Check if the mouse painter should indicate that
                    % the object can be moved

                    if strcmpi(obj.faceColor,'none')

                        if ~strcmpi(obj.edgeColor,'none')

                            values = [x(1) - xx;
                                      x(2) - xx;
                                      y(3) - yy;
                                      y(4) - yy];
                            check  = min(abs(values));      
                            if check < tol 
                                pointer = 'hand';
                            else
                                pointer = '';
                            end

                        else
                            pointer = '';
                        end

                    else
                        if xx > pos(1) && xx < pos(1) + pos(3) ...
                           && yy > pos(2) && yy < pos(2) + pos(4) 

                            pointer = 'hand';

                        else
                            pointer = '';
                        end

                    end

                else

                    % Indicate by the mouse pointer that the object
                    % can be resized

                    ret = 1;
                    if strcmpi(obj.edgeColor,'same')
                        if strcmpi(obj.edgeColor,'none')
                            ret = 0;
                        end
                    elseif strcmpi(obj.edgeColor,'none')
                        ret = 0;
                    end
                    if ret
                        ind = ind(1);
                        switch ind
                            case 1
                                pointer = 'left';
                            case 2
                                pointer = 'right';
                            case 3
                                pointer = 'top';
                            case 4
                                pointer = 'bottom';
                        end

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
        
        function childrenPos = objectPos2childrenPos(obj)
            
            ax  = obj.parent;
            pos = ax.position;
            switch lower(obj.units)
        
                case 'data' 

                    % Find the rectangle location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(obj.position(1),ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');
                    ww = nb_dpos2dpos(obj.position(3),ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');

                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(obj.position(2),ax.yLimRight,[pos(2),pos(2) + pos(4)],ax.yScaleRight,'normal');
                        hh = nb_dpos2dpos(obj.position(4),ax.yLimRight,[pos(2),pos(2) + pos(4)],ax.yScaleRight,'normal');
                    else
                        yy = nb_pos2pos(obj.position(2),ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                        hh = nb_dpos2dpos(obj.position(4),ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                    end

                case 'normalized'

                    xx = obj.position(1);
                    xx = pos(1) + xx*pos(3);
                    ww = obj.position(3)*pos(3);
                    yy = obj.position(2);  
                    yy = pos(2) + yy*pos(4);
                    hh = obj.position(4)*pos(4);

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end
            
            childrenPos = [xx,yy,ww,hh];
            
        end
        
        function axesPos = objectPos2axesPos(obj)
            
            ax = obj.parent;
            switch lower(obj.units)
        
                case 'data' 

                    % Find the rectangle location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(obj.position(1),ax.xLim,[0,1],ax.xScale,'normal');
                    ww = nb_dpos2dpos(obj.position(3),ax.xLim,[0,1],ax.xScale,'normal');

                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(obj.position(2),ax.yLimRight,[0,1],ax.yScaleRight,'normal');
                        hh = nb_dpos2dpos(obj.position(4),ax.yLimRight,[0,1],ax.yScaleRight,'normal');
                    else
                        yy = nb_pos2pos(obj.position(2),ax.yLim,[0,1],ax.yScale,'normal');
                        hh = nb_dpos2dpos(obj.position(4),ax.yLim,[0,1],ax.yScale,'normal');
                    end
                    axesPos = [xx,yy,ww,hh];
                    
                case 'normalized'

                    axesPos = obj.position;

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end
            
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
        
        function leftResize(obj)
        % Resize the rectangle left side   
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            xx                = cPoint(1);
            
            % Update the children
            %------------------------------------------------------
            childrenPos       = get(obj.children,'position');
            childrenPosNew    = childrenPos;
            childrenPosNew(1) = xx;
            childrenPosNew(3) = childrenPos(1) + childrenPos(3) - xx;
            if childrenPosNew(3) < 0
                childrenPosNew(3) = abs(childrenPosNew(3));
                childrenPosNew(1) = childrenPosNew(1) - childrenPosNew(3);
            elseif isequal(childrenPosNew(3),0)
                childrenPosNew(3) = exp(-5);
            end
            set(obj.children,'position',childrenPosNew);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
            switch lower(obj.units)

                case 'data' 

                    newPos1 = nb_pos2pos(cAxPoint(1),[0,1],ax.xLim,'normal',ax.xScale);
                    newPos3 = obj.position(1) + obj.position(3) - newPos1;
                    
                case 'normalized'

                    newPos1 = cAxPoint(1);
                    newPos3 = obj.position(1) + obj.position(3) - newPos1;  
                    
            end
            
            if newPos3 < 0
                obj.position(1) = newPos1 + newPos3;
                obj.position(3) = abs(newPos3);
            else
                obj.position(1) = newPos1;
                obj.position(3) = newPos3;
            end
            
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function rightResize(obj)
        % Resize the rectangle right side   
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            xx                = cPoint(1);
            
            % Update the children
            %------------------------------------------------------
            childrenPos       = get(obj.children,'position');
            childrenPosNew    = childrenPos;
            childrenPosNew(3) = xx - childrenPos(1);
            if childrenPosNew(3) < 0
                childrenPosNew(3) = abs(childrenPosNew(3));
                childrenPosNew(1) = childrenPosNew(1) - childrenPosNew(3);
            elseif isequal(childrenPosNew(3),0)
                childrenPosNew(3) = exp(-5);    
            end
            set(obj.children,'position',childrenPosNew);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
            switch lower(obj.units)

                case 'data' 

                    newPos3 = nb_pos2pos(cAxPoint(1),[0,1],ax.xLim,'normal',ax.xScale) - obj.position(1);
                    
                case 'normalized'

                    newPos3 = cAxPoint(1) - obj.position(1);
                    
            end
            
            if newPos3 < 0
                obj.position(1) = obj.position(1) + newPos3;
                obj.position(3) = abs(newPos3);
            else
                obj.position(3) = newPos3;
            end 
            
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function topResize(obj)
        % Resize the rectangle top side    
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            yy                = cPoint(2);
            
            % Update the children
            %------------------------------------------------------
            childrenPos       = get(obj.children,'position');
            childrenPosNew    = childrenPos;
            childrenPosNew(4) = yy - childrenPos(2);
            if childrenPosNew(4) < 0
                childrenPosNew(4) = abs(childrenPosNew(4));
                childrenPosNew(2) = childrenPosNew(2) - childrenPosNew(4);
            elseif isequal(childrenPosNew(4),0)
                childrenPosNew(4) = exp(-5);    
            end
            set(obj.children,'position',childrenPosNew);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
            switch lower(obj.units)

                case 'data' 

                    if strcmpi(obj,'right')
                        newPos4 = nb_pos2pos(cAxPoint(2),[0,1],ax.yLimRight,'normal',ax.yScaleRight) - obj.position(2);
                    else
                        newPos4 = nb_pos2pos(cAxPoint(2),[0,1],ax.yLim,'normal',ax.yScale) - obj.position(2);
                    end
                    
                case 'normalized'

                    newPos4 = cAxPoint(2) - obj.position(2);
                    
            end
            
            if newPos4 < 0
                obj.position(2) = obj.position(2) + newPos4;
                obj.position(4) = abs(newPos4);
            else
                obj.position(4) = newPos4;
            end   
            
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
        end
        
        function bottomResize(obj)
        % Resize the rectangle bottom side    
            
            % Get the new value
            %------------------------------------------------------
            [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            yy                = cPoint(2);
            
            % Update the children
            %------------------------------------------------------
            childrenPos       = get(obj.children,'position');
            childrenPosNew    = childrenPos;
            childrenPosNew(2) = yy;
            childrenPosNew(4) = childrenPos(2) + childrenPos(4) - yy;
            if childrenPosNew(4) < 0
                childrenPosNew(4) = abs(childrenPosNew(4));
                childrenPosNew(2) = childrenPosNew(2) - childrenPosNew(4);
            elseif isequal(childrenPosNew(4),0)
                childrenPosNew(4) = exp(-5);    
            end
            set(obj.children,'position',childrenPosNew);
            
            % Update the object itself.
            %------------------------------------------------------
            ax = obj.parent;
            switch lower(obj.units)

                case 'data' 

                    if strcmpi(obj,'right')
                        newPos2 = nb_pos2pos(cAxPoint(2),[0,1],ax.yLimRight,'normal',ax.yScaleRight);
                    else
                        newPos2 = nb_pos2pos(cAxPoint(2),[0,1],ax.yLim,'normal',ax.yScale);
                    end
                    newPos4 = obj.position(2) + obj.position(4) - newPos2;
                    
                case 'normalized'

                    newPos2 = cAxPoint(2);
                    newPos4 = obj.position(2) + obj.position(4) - newPos2;  
                    
            end
            
            if newPos4 < 0
                obj.position(2) = newPos2 + newPos4;
                obj.position(4) = abs(newPos4);
            else
                obj.position(2) = newPos2;
                obj.position(4) = newPos4;
            end
            
            obj.selected = 0;
            
            notify(obj,'annotationMoved');
            
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
            
            nb_editDrawPatch(obj);
        
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
