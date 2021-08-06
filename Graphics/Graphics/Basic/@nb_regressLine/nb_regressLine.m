classdef nb_regressLine < nb_textAnnotation & nb_lineAnnotation
% Superclasses:
% 
% nb_textAnnotation, nb_annotation, handle
%     
% Description:
%     
% A class for adding a regression line to a scatter plot.
%     
% Constructor:
%     
%     obj = nb_regressLine(varargin)
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
%     - obj      : An object of class nb_regressLine
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
        % nRegLines x 3. With the RGB colors. Or a string with the name of 
        % the color. See the method interpretColor of the 
        % nb_plotHandle class for more on the supported color names.
        cData                       = [0 0 0];    
                  
        % {'on'} | 'off' ; Clipping mode. MATLAB clips lines to the 
        % axes plot box by default. If you set Clipping to off, 
        % lines are displayed outside the axes plot box.
        clipping                    = 'on';         
         
        % Number of decimals. Default is 2.
        decimals                    = 2;
        
        % Horizontal alignment of text. Specifies the horizontal 
        % justification of the text string. Must be a string. 
        % {'left'} | 'center' | 'right'.
        horizontalAlignment         = 'left';
         
        % Selects the scatter plot to add the regression line to. I.e.
        % if there is plotted to scatter plots to an axes this property can
        % be set to either 1 or 2. (If <1, 1 is selected. If >2, 2 is 
        % selected. In this example)
        index                       = 1;
        
        % Interpret TeX instructions. Must be a string. 'latex' |
        % {'tex'} | 'none'.
        interpreter                 = 'tex';
        
        % The line style of the plotted data. Must be a string.
        % {'-'} | '--' | ':' | '-.' | 'none'. '---' is not 
        % supported.                                    
        lineStyle                   = '-';     
        
        % The line width of the plotted data. As an integer.
        lineWidth                   = 1.5;          
        
        % The markers of the lines. Must be a string. See marker 
        % property of the MATLAB line function for more on the 
        % options of this property
        marker                      = 'none';    
        
        % A 1x3 double with the RGB colors | 'none' | {'auto'}.
        markerEdgeColor             = 'auto';    
        
        % A 1x3 double with the RGB colors | 'none' | {'auto'}.
        markerFaceColor             = 'auto';       
        
        % Size of the markers. Must be a integer. Default is 9.
        markerSize                  = 9; 
        
        % Manually set the x-axis position of the label. Must be a 
        % 1 x nRegLines double.
        positionX                   = [];
        
        % Manually set the x-axis position of the label. Must be a 
        % 1 x nRegLines double.
        positionY                   = [];
         
        % Text of regression line label. Default is the regression equation
        % and R^{2} results. Must be a 1 x nRegLines cellstr.
        string                      = {};
       
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
        
        % Vertical alignment of text. Specifies the vertical 
        % justification of the text string. Must be a string.
        % {'top'} | 'cap' | 'middle' | 'baseline' | 'bottom'.
        verticalAlignment           = 'top';
        
        
    end
    
    properties (Hidden=true)
        
        beta        = [];
        rSquared    = [];
        side        = 'left';
        units       = 'data';
        xData       = [];
        yData       = [];
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_regressLine(varargin)
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
                for ii = 1:length(obj.children)
                    if isa(obj.children{ii},'nb_plot')
                        if isvalid(obj.children{ii})
                            obj.children{ii}.deleteOption = 'all';
                            delete(obj.children{ii})
                        end
                    elseif ishandle(obj.children{ii})
                        delete(obj.children{ii})
                    end
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
           s.class = 'nb_regressLine';

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
            
            scatterObj = ax.children;
            indS       = cellfun(@(x)isa(x,'nb_scatter'),scatterObj);
            scatterObj = scatterObj(indS);
            if isempty(scatterObj)
                % Delete the old object plotted by this object
                %----------------------------------------------------------
                deleteChildren(obj)
                return
            end
            
            numC = length(scatterObj);
            if obj.index < 1
                selected = 1;
            elseif obj.index > numC
                selected = numC;
            else
                selected = obj.index;
            end
            scatterObj = scatterObj{selected};
           
            % Delete the old object plotted by this object
            %--------------------------------------------------------------
            deleteChildren(obj);
            
            % Do the regression
            %-------------------
            x        = scatterObj.xData;
            y        = scatterObj.yData;
            numLines = size(x,2);
            bet      = nan(2,numLines);
            rSq      = nan(1,numLines);
            xD       = [min(x,[],1);max(x,[],1)];
            yD       = nan(2,numLines);
            for ii = 1:numLines
               [bet(:,ii),~,~,~,res]  = nb_ols(y(:,ii),x(:,ii),true); 
               rSq(:,ii)              = nb_rSquared(y(:,ii),res,2);
               yD(:,ii)               = bet(1,ii) + bet(2,ii)*xD(:,ii);
            end
            obj.xData    = xD;
            obj.yData    = yD;
            obj.beta     = bet;
            obj.rSquared = rSq;
            obj.side     = scatterObj.side;
            
            % Get the coordinates
            %--------------------------------------------------------------
            [xx,yy] = objectPos2axesPos(obj);

            % Test the color specification
            %--------------------------------------------------------------
            if ischar(obj.cData) || iscellstr(obj.cData)
                color = nb_plotHandle.interpretColor(obj.cData);
            else
                color = obj.cData;
            end
            if size(color,1) < numLines
                color = [color;...
                         color(ones(1,numLines - size(color,1)),:)]; 
            elseif size(color,1) > numLines
                color = color(1:numLines,:);
            end
            obj.cData = color;

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
            l = nb_plot(xx,yy,...
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

            % Text boxes
            %------------
            if length(obj.string) < numLines
                obj.string = [obj.string,repmat({{'y   = %#alpha  + %#betax';'R^{2} = %#rsq'}},[1,numLines - length(obj.string)])];
            elseif length(obj.string) > numLines
                obj.string = obj.string(1:numLines);
            end
            
            if length(obj.positionX) < numLines
                obj.positionX = [obj.positionX,nan(1,numLines - length(obj.positionX))];
            elseif length(obj.positionX) > numLines
                obj.positionX = obj.positionX(1:numLines);
            end
            
            if length(obj.positionY) < numLines
                obj.positionY = [obj.positionY,nan(1,numLines - length(obj.positionY))];
            elseif length(obj.positionY) > numLines
                obj.positionY = obj.positionY(1:numLines);
            end
            
            posX = obj.positionX;
            posY = obj.positionY;
            t    = cell(1,numLines);
            for ii = 1:numLines
                str = obj.string{ii};
                for jj = 1:size(str,1)
                    str{jj} = strrep(str{jj},'%#alpha',num2str(obj.beta(1,ii),obj.decimals));
                    str{jj} = strrep(str{jj},'%#beta',num2str(obj.beta(2,ii),obj.decimals));
                    str{jj} = strrep(str{jj},'%#rsq',num2str(obj.rSquared(ii),obj.decimals));
                end
                if isnan(posX(ii))
                    xT = xx(1,ii);
                else
                    xT = posX(ii);
                end
                if isnan(posY(ii))
                    yT = yy(1,ii);
                else
                    yT = posY(ii);
                end
                t{ii} = text(xT,yT,str,...
                             'interpreter',         'tex',...
                             'verticalAlignment',   obj.verticalAlignment,...
                             'horizontalAlignment', obj.horizontalAlignment,...
                             'parent',              axh,...
                             'backgroundColor',     obj.textBackgroundColor,...
                             'color',               obj.textColor,...
                             'edgeColor',           obj.textEdgeColor,...
                             'lineWidth',           obj.textLineWidth,...
                             'margin',              obj.textMargin,...
                             'rotation',            obj.textRotation,...
                             'interpreter',         obj.interpreter,...
                             'fontSize',            obj.fontSize,...
                             'fontUnits',           obj.fontUnits,...
                             'fontWeight',          obj.fontWeight);
            end
            obj.children = [{l},t];
            
            % Add a uicontext menu to the arrow
            %------------------------------------------------------
            childs = l.children;
            childs = [childs.children]; % Get the MATLAB line handles
            cMenu  = uicontextmenu('parent',ax.parent.figureHandle); 
                     uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                     if obj.copyOption
                     uimenu(cMenu,'Label','Copy','Callback',@obj.copyCallback);
                     end
                     uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
            set(childs,'UIContextMenu',cMenu)  
            
            
        end
        
        function [xx,yy] = objectPos2axesPos(obj)
            
            ax  = obj.parent;
            axh = ax.axesLabelHandle;
            switch lower(obj.units)
        
                case 'data' 

                    % Find the rectangle location in normalized units
                    %------------------------------------------------------
                    xx = nb_pos2pos(obj.xData,ax.xLim,get(axh,'xLim'),ax.xScale,'normal');
                    if strcmpi(obj.side,'right')
                        yy = nb_pos2pos(obj.yData,ax.yLimRight,get(axh,'yLim'),ax.yScaleRight,'normal');
                    else
                        yy = nb_pos2pos(obj.yData,ax.yLim,get(axh,'yLim'),ax.yScale,'normal');
                    end
                    
                case 'normalized'

                    xx = obj.xData;
                    yy = obj.yData;

                otherwise

                    error([mfilename ':: The units property can only be set to ''data'' or ''normalized''.'])

            end
            
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the 
        % annotation handle
            
            nb_editRegressLine(obj);
        
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
             
           obj    = nb_regressLine(); 
           s      = rmfield(s,'class');
           fields = fieldnames(s);
           for ii = 1:length(fields)
               obj.(fields{ii}) = s.(fields{ii});
           end
           
        end
        
    end
    
end
