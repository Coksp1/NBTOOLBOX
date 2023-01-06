classdef nb_curlyBrace < nb_annotation & nb_movableAnnotation & nb_lineAnnotation
% Superclasses:
% 
% nb_movableAnnotation, nb_lineAnnotation, nb_annotation, handle
%     
% Description:
%     
% A class for adding a curly brace to the plot.
%
% The code for plotting the curly brace is gotten from the drawbrace
% functionn made by Pål Næverlid Sævik.
%
% Constructor:
%     
%     obj = nb_curlyBrace(varargin)
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
%     - obj      : An object of class nb_curlyBrace
%     
% See also:
% nb_annotation, nb_graph_ts, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
        
        % The color data of the line plotted. Must be of size;
        % 1 x 3. With the RGB colors. Or a string with the name of 
        % the color. See the method interpretColor of the 
        % nb_plotHandle class for more on the supported color names.
        cData               = [0 0 0];    
                  
        % {'on'} | 'off' ; Clipping mode. MATLAB clips lines to the 
        % axes plot box by default. If you set Clipping to off, 
        % lines are displayed outside the axes plot box.
        clipping            = 'off';         
           
        % The line style of the plotted data. Must be a string.
        % {'-'} | '--' | ':' | '-.' | 'none'. '---' is not 
        % supported.                                    
        lineStyle           = '-';     
        
        % The line width of the plotted data. As an integer.
        lineWidth           = 2.5;          
        
        % The markers of the lines. Must be a string. See marker 
        % property of the MATLAB line function for more on the 
        % options of this property
        marker              = 'none';    
        
        % A 1x3 double with the RGB colors | 'none' | {'auto'}.
        markerEdgeColor     = 'auto';    
        
        % A 1x3 double with the RGB colors | 'none' | {'auto'}.
        markerFaceColor     = 'auto';       
        
        % Size of the markers. Must be a integer. Default is 9.
        markerSize          = 9;           
        
        % The axes to plot against. 'left' or 'right'. 'left'  is
        % default.
        side                = 'left';
        
        % The coordinates system to plot in. Either {'data'} : 
        % xy-coordinates | 'normalized' : figure coordinates.
        units               = 'data';       
        
        % Width of the brace. Try and fale method must be used!
        width               = 10;
        
        % The x-axis data. As a 1x2 double.
        xData               = [];
        
        % The y-axis data. As a 1x2 double.
        yData               = [];             
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_curlyBrace(varargin)
        % Constructor
        
            if nargin > 0
                
                set(obj,varargin);
                
            end
                 
        end
        
        varargout = set(varargin)
        
        function lineWidth = get.lineWidth(obj)
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
        end
        
        function markerSize = get.markerSize(obj)
           markerSize = nb_scaleLineWidth(obj,obj.markerSize); 
        end
        
        function update(obj)

            plot(obj);

        end
         
    end
    
    methods(Access=public,Hidden=true)
        
        % Override
        function deleteChildren(obj)
            if ~isempty(obj.children) && isvalid(obj.children)
                obj.children.deleteOption = 'all';
                delete(obj.children)
            end
            
            delete(obj.listeners);
        end
        
        function s = struct(obj)
            
           obj.returnNonScaled = true; 
            
           s = struct(...
                'cData',            obj.cData,...
                'class',            class(obj),...
                'clipping',         obj.clipping,...
                'lineStyle',        obj.lineStyle,...
                'lineWidth',        obj.lineWidth,...
                'marker',           obj.marker,...
                'markerEdgeColor',  obj.markerEdgeColor,...
                'markerFaceColor',  obj.markerFaceColor,...
                'markerSize',       obj.markerSize,...
                'side',             obj.side,...
                'units',            obj.units,...
                'width',            obj.width,...
                'xData',            obj.xData,...
                'yData',            obj.yData,...
                'deleteOption',     obj.deleteOption); 
            
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
                warning([mfilename ':: You must provide the properties ''xData'' and ''yData''. No brace is plotted!'])

                % Delete the old object plotted by this object
                obj.deleteChildren();
            end

            % Delete the old object plotted by this object
            obj.deleteChildren();

            % Decide the axes to plot against
            %--------------------------------------------------------------      
            axh = ax.axesLabelHandle; 
            
            % Get the coordinates
            %--------------------------------------------------------------
            [xx,yy] = objectPos2axesPos(obj);
            [x,y]   = nb_curlyBrace.getCoordinates(axh,xx,yy,obj.width);
            
            % Test the color specification
            %--------------------------------------------------------------
            if ischar(obj.cData)
                color = nb_plotHandle.interpretColor(obj.cData);
            else
                color = obj.cData;
            end

            if ischar(obj.markerFaceColor)
                if ~strcmpi(obj.markerFaceColor,'none') && ~strcmpi(obj.markerFaceColor,'auto')
                    faceCData = nb_plotHandle.interpretColor(obj.markerFaceColor);
                else
                    faceCData = obj.markerFaceColor;
                end
            else
                faceCData = obj.markerFaceColor;
            end

            if ischar(obj.markerEdgeColor)
                if ~strcmpi(obj.markerEdgeColor,'none') && ~strcmpi(obj.markerFaceColor,'auto')
                    edgeCData = nb_plotHandle.interpretColor(obj.markerEdgeColor);
                else
                    edgeCData = obj.markerEdgeColor;
                end
            else
                edgeCData = obj.markerEdgeColor;
            end

            % Plot the line
            %--------------------------------------------------------------
            l     = nb_line(x,y,...
                    'clipping',         obj.clipping,...
                    'cData',            color,...
                    'legendInfo',       'off',...
                    'lineStyle',        obj.lineStyle,...
                    'lineWidth',        obj.lineWidth,...
                    'marker',           obj.marker,...
                    'markerEdgeColor',  edgeCData,...
                    'markerFaceColor',  faceCData,...
                    'markerSize',       obj.markerSize,...
                    'side',             obj.side,...
                    'parent',           axh);

            obj.children = l;
            
            % Add a uicontext menu to the arrow
            %------------------------------------------------------
            cMenu = uicontextmenu('parent',ax.parent.figureHandle); 
                 uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                 if obj.copyOption
                 uimenu(cMenu,'Label','Copy','Callback',@obj.copyCallback);
                 end
                 uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
            set(obj.children.children,'UIContextMenu',cMenu)  
            
            % Add listener to the current position of the mouse.
            %------------------------------------------------------
            obj.listeners = [...
                addlistener(obj.parent.parent,'mouseMove',@obj.mouseMoveCallback), ...
                addlistener(obj.parent.parent,'mouseDown',@obj.mouseDownCallback), ...
                addlistener(obj.parent.parent,'mouseUp',@obj.mouseUpCallback)];
            
        end
        
        function [xx,yy] = objectPos2axesPos(obj)
            
            ax  = obj.parent;
            pos = ax.position;
            switch lower(obj.units)

                case 'data' 

                    % Find the location in normalized units
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
            
        end
        
        function mouseMoveCallback(obj, ~, ~)
        
            if ~isvalid(obj)
                return
            end
        
            if ~isempty(obj.children) && isvalid(obj.children) && ...
                    ~ishandle(obj.children.children) 
                return
            end
            
            pointer = [];
            
            if obj.selected
                pointer = obj.pointer;
            else     
                
                if isempty(obj.parent)
                    return
                end

                cAxPoint     = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
                [xPos,yPos]  = objectPos2axesPos(obj);
                [xPos,yPos]  = nb_curlyBrace.getCoordinates(obj.parent.axesLabelHandle,xPos,yPos,obj.width);

                % Get the selection resize position
                %------------------------------------------------------
                s = length(xPos)/4;
                x = [xPos(1:s);
                     xPos(end-s+1:end)];

                y = [yPos(1:s);
                     yPos(end-s+1:end)];

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

                    distance = sqrt((xPos - xx).^2 + (yPos - yy).^2);
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
        % This function is called when the user click while holding
        % the mouse above this object. 
            
            if ~isvalid(obj)
                return
            end
        
            % Get figure handle
            fig = obj.parent.parent.figureHandle;
            
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
        % Move start of arrow  
            
            % Get the new value
            %------------------------------------------------------
            [~,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
            % Update the object
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
            plot(obj);
            
            notify(obj,'annotationMoved');
            
        end
        
        function endMove(obj,~,~)
        % Resize the rectangle left side   
            
            % Get the new value
            %------------------------------------------------------
            [~,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
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
            plot(obj);
            
            notify(obj,'annotationMoved');
            
        end
        
        function move(obj,~,~)
            
            % Get the new value
            %------------------------------------------------------
            [~,cAxPoint] = nb_getCurrentPointInAxesUnits(obj.parent.parent,obj.parent);
            
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
            plot(obj)
            
            notify(obj,'annotationMoved');
            
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the 
        % annotation handle
            
            nb_editCurlyBrace(obj);
        
        end
        
        function deleteCallback(obj,~,~)
        % Callback function called when user click on the delete 
        % option of the uicontextmenu handle attached to the annotation
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
        
        function [x,y] = getCoordinates(axh,xx,yy,widthT)
            
            % Get axis size
            pos   = get(axh, 'Position');
            par   = get(axh,'parent');
            old   = get(par,'units');
            set(par,'units','pixels');
            opos  = get(par, 'Position');
            set(par,'units',old)
            ylims = get(axh,'yLim');
            xlims = get(axh,'xLim');
    
            % Take logarithmic scale into account
            isxlog = strcmp(get(axh,'XScale'),'log');
            isylog = strcmp(get(axh,'YScale'),'log');
            if isxlog
                xx    = log(xx);
                xlims = log(xlims);
            end
            if isylog
                yy    = log(yy);
                ylims = log(ylims);
            end
    
            % Transform from axis to screen coordinates
            start  = [xx(1),yy(1)];
            stop   = [xx(2),yy(2)];
            xscale = pos(3) * opos(3) / diff(xlims);
            yscale = pos(4) * opos(4) / diff(ylims);
            start  = (start - [xlims(1) ylims(1)]) .* [xscale yscale];
            stop   = (stop - [xlims(1) ylims(1)]) .* [xscale yscale];
            
            % Find standard width
            if isempty(widthT)
                widthT = 10;%norm(stop - start)/10; 
            end
    
            % Find brace points
            th = atan2(stop(2)-start(2), stop(1)-start(1));
            c1 = start + widthT*[cos(th) sin(th)];
            c2 = 0.5*(start+stop) + 2*widthT*[-sin(th) cos(th)] - widthT*[cos(th) sin(th)];
            c3 = 0.5*(start+stop) + 2*widthT*[-sin(th) cos(th)] + widthT*[cos(th) sin(th)];
            c4 = stop - widthT*[cos(th) sin(th)];
    
            % Assemble brace coordinates
            q      = linspace(0+th, pi/2+th, 50)';
            t      = flipud(q);
            part1x = widthT*cos(t+pi/2) + c1(1);
            part1y = widthT*sin(t+pi/2) + c1(2);
            part2x = widthT*cos(q-pi/2) + c2(1);
            part2y = widthT*sin(q-pi/2) + c2(2);
            part3x = widthT*cos(q+pi) + c3(1);
            part3y = widthT*sin(q+pi) + c3(2);
            part4x = widthT*cos(t) + c4(1);
            part4y = widthT*sin(t) + c4(2);
            x      = [part1x; part2x; part3x; part4x];
            y      = [part1y; part2y; part3y; part4y];

            % Transform back to axis coordinates
            x = x/xscale + xlims(1);
            y = y/yscale + ylims(1);
            if isxlog
                x = exp(x); 
            end
            if isylog
                y = exp(y); 
            end
            
        end
        
        function obj = unstruct(s)
             
           obj                 = nb_curlyBrace(); 
           obj.cData           = s.cData;
           obj.clipping        = s.clipping;
           obj.lineStyle       = s.lineStyle;
           obj.lineWidth       = s.lineWidth;
           obj.marker          = s.marker;
           obj.markerEdgeColor = s.markerEdgeColor;
           obj.markerFaceColor = s.markerFaceColor;
           obj.markerSize      = s.markerSize;
           obj.side            = s.side;
           obj.units           = s.units;
           if isfield(s,'width')
                obj.width = s.width;
           end
           obj.xData           = s.xData;
           obj.yData           = s.yData;
           obj.deleteOption    = s.deleteOption;
            
        end
        
    end
    
end
