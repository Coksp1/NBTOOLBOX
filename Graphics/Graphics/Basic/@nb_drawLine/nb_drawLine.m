classdef nb_drawLine < nb_annotation & nb_lineAnnotation
% Superclasses:
% 
% nb_lineAnnotation, nb_annotation, handle
%     
% Description:
%     
% A class for adding a arbitary line to a plot.
%     
% Constructor:
%     
%     obj = nb_drawLine(varargin)
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
%     - obj      : An object of class nb_drawLine
%     
%     Examples:
%   
% See also:
% nb_annotation, nb_graph_ts, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        clipping            = 'on';         
           
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
        
        % The x-axis data. As a double.
        xData               = [];
        
        % The y-axis data. As a double.
        yData               = [];             
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_drawLine(varargin)
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
        
        function deleteChildren(obj)
        % Delete object
        
            if ~isempty(obj.children)
                if isvalid(obj.children)
                    obj.children.deleteOption = 'all';
                    delete(obj.children)
                end
            end
            
        end
         
    end
    
    methods(Access=public,Hidden=true)
        
        function s = struct(obj)
            
           obj.returnNonScaled = true; 
            
           s     = struct();
           props = properties(obj);
           for ii = 1:length(props)
              s.(props{ii}) = obj.(props{ii});
           end
           s.class = 'nb_drawLine';
            
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
                warning('nb_drawLine:NoPlottedLine',[mfilename ':: You must provide the properties ''xData'' and ''yData''. No line is plotted!'])

                % Delete the old object plotted by this object
                %----------------------------------------------------------
                deleteChildren(obj);
                return
            end
            
            if isrow(obj.xData)
                obj.xData = obj.xData';
            end
            if isrow(obj.yData)
                obj.yData = obj.yData';
            end

            % Delete the old object plotted by this object
            %--------------------------------------------------------------
            deleteChildren(obj);

            % Get the coordinates
            %--------------------------------------------------------------
            pos = ax.position;
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

            % Decide the axes to plot against
            %--------------------------------------------------------------      
            axh = ax.axesLabelHandle; 

            % Plot the line
            %--------------------------------------------------------------
            l = nb_line(xx,yy,...
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
            childs = l.children; % Get the MATLAB line handles
            cMenu  = uicontextmenu('parent',ax.parent.figureHandle); 
                     uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                     if obj.copyOption
                     uimenu(cMenu,'Label','Copy','Callback',@obj.copyCallback);
                     end
                     uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
            set(childs,'UIContextMenu',cMenu)  
            
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the 
        % annotation handle
            
            nb_editDrawLine(obj);
        
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
             
           obj    = nb_drawLine(); 
           s      = rmfield(s,'class');
           fields = fieldnames(s);
           for ii = 1:length(fields)
               obj.(fields{ii}) = s.(fields{ii});
           end
            
        end
        
    end
    
end
