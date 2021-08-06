classdef nb_patch < nb_plotHandle
% Syntax:
%     
% obj = nb_patch(xData,yData,cData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for making patches. 
%     
% This class makes shaded patches which doesn't return a warning 
% when printed by the export_fig function developed by Oliver 
% Woodford    
%     
% Caution : 
% 
%     - Not all functionalities of the patch class is supported by 
%       this class.
%     
%     - The transparency options is not supported by the export_fig
%       function when the renderer is set to 'painters' (Which is 
%       default for .eps and .pdf files). Use 'openGL'.
%     
%     - The lighting options is only supported by the renderer 
%       'openGL' 
%     
%     - This class does not support zData.
%     
%     - Only rectangular patches will be shaded correctly at the 
%       moment
% 
% Constructor:
%     
%     obj = nb_patch(xData,yData,cData,varargin)
%     
%     Input:
%
%     - xData    : The x-axis values of the plotted patch. If only  
%                  one input is given to this constructor it will 
%                  be interpreted as the yData input. (Then the  
%                  xData will be 1:size(yData,1)). Must be a double 
%                  vector.
%                        
%     - yData    : The yData of the plot. Must be a double vector.
%               
%
%     - cData    : The RGB color of the patch, if it has two values
%                  the color will be interpolated. The first RGB 
%                  values will at the bottom of the patch.
%
%                  Must be a 1 x 3 double (or 2 x 3 double vector
%                  when using shading) with the RGB colors or
%                  a cellstr with the color names. See the 
%                  method interpretColor of the nb_plotHandle 
%                  class for more on the supported color names.
%
%                  If not provided the color 'black' is used.
%
%     Optional input:
%
%     - varargin : ...,'propertyName',propertyValue,...  
%     
%     Output
% 
%     - obj      : An object of class nb_patch
%     
%     Examples:
%   
%     nb_patch(yData)
%     nb_patch(xData,yData)
%     nb_patch(xData,yData,cData)  
%     nb_patch(xData,yData,cData,'propertyName',propertyValue,...)
%     handle = nb_patch(xData,yData,cData,'propertyName',...
%                       propertyValue,...)  
%
% See also:
% patch, surface, fill
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(SetAccess = protected)
                
        % All the children (patch and line handles) of the nb_patch object
        children = []; 
     
    end
        
    properties
        
        % The RGB color of the patch, if it has two values
        % the color will be interpolated. The first RGB 
        % values will at the bottom of the patch.
        % 
        % Must be a 1 x 3 double (or 2 x 3 double vector
        % when using shading) with the RGB colors or
        % a string with the color name. See the 
        % method interpretColor of the nb_plotHandle 
        % class for more on the supported color names.
        cData        = []; 
        
        % 'on' or 'off'. Clipping to axes rectangle. When Clipping 
        % is on, MATLAB does not display any portion of the patch 
        % outside the axes rectangle.
        clipping     = 'on';   
        
        % {'on'} | 'off' ; Clipping mode. MATLAB clips
        % lines to the axes plot box by default. If you
        % set Clipping to off, lines are displayed 
        % outside the axes plot box.
        deleteOption = 'only'; 
        
        % Direction of the shading; {'north'} | 'south' | 'west' | 
        % 'east'
        direction    = 'north';  
        
        % The color of the edge of the bars. In RGB 
        % colors | 'none' : No edgeLine | 'same' : Same
        % color as the base color for each bar |
        % a string with the color name.
        edgeColor    = 'same';   
        
        % Transparency of the patch face. Only the scalar option is 
        % supported. A single non-NaN value between 0 and 1 that 
        % controls the transparency of all the faces of the object. 
        % 1 (the default) means fully opaque and 0 means completely 
        % transparent (invisible)
        faceAlpha    = 1; 
        
        % See the patch properties for more on this option 
        faceLighting = 'none';   
        
        % {'off'} : Not included in the legend. 'on' : 
        % included in the legend
        legendInfo   = 'on'       
        
        % The line style of the edge of the patch.
        lineStyle    = '-';  
        
        % The line width of the edge of the patch.
        lineWidth    = 1.5;       
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default)
        side         = 'left';
        
        % Patch object visibility. 'on' : The patch is visible. 
        % 'off' : The patch is not visible, but still exists, and 
        % you can query and set its properties.
        visible      = 'on'; 
        
        % The x values of the patch. Same as for the MATLAB patch 
        % class
        xData        = [];    
        
        % The y values of the patch. Same as for the MATLAB patch 
        % class
        yData        = [];        
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        shaded       = 0;         % Identifier if the patch should be shaded or not
        type         = 'patch';
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
        function set.cData(obj,value)
            if ~nb_isColorProp(value,true)
                error([mfilename ':: The cData property must'...
                                 ' must have dimension size'...
                                 ' size(plotData,2) x 3 with the RGB'...
                                 ' colors or a cellstr with size 1 x'...
                                 ' size(yData,2) with the color names.'])
            end
            obj.cData = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename '::  The visible property must be '...
                      'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end    
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.direction(obj,value)
            if ~any(strcmp({'south','west','north','south'},value))
                error([mfilename ':: The direction property must be'...
                                 ' set to either ''south'', ''east'','...
                                 ' ''west'', or north.'])
            end
            obj.direction = value;
        end        
        
        function set.edgeColor(obj,value)
            if ~any(strcmp({'none','same'},value)) && ...
                                                    ~nb_isColorProp(value)
                error([mfilename ':: The edgeColor property must be'...
                                 ' set to either ''none'' or ''same''.'])
            end
            obj.edgeColor = value;
        end

        function set.faceAlpha(obj,value)
            if (value < 0 || value > 1) && nb_isScalarNumber(value)
                error([mfilename ':: The faceAlpha property must be'...
                                 ' set to a value contained in [0,1].'])
            end
            obj.faceAlpha = value;
        end
        
        function set.faceLighting(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The faceLighting property must be'...
                                 ' given as a one line character array.'])
            end
            obj.faceLighting = value;
        end      
        

        function set.legendInfo(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The legendInfo property must be'...
                                 ' set to either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
        end        
        
        function set.lineStyle(obj,value)
            if ~nb_islineStyle(value)
                error([mfilename ':: The lineStyle property must be'...
                                 ' given as a valid line style.'])
            end
            obj.lineStyle = value;
        end
        
        function set.lineWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The lineWidth property must be'...
                                 ' given as a scalar double.'])
            end
            obj.lineWidth = value;
        end        
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename ':: The side property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.side = value;
        end          
        
        function set.xData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The xData property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.xData = value;
        end    
        
        function set.yData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.yData = value;
        end                           
        
        function obj = nb_patch(xData,yData,cData,varargin)
           
            if nargin < 3
                cData = [51, 51, 51]/255;
                if nargin < 2
                    yData = [0; 1; 1; 0];
                    if nargin < 1
                        xData = [0; 0 ; 1; 1];
                    end
                end
            end
            
            % Assign properties
            obj.xData = xData;
            obj.yData = yData;
            obj.cData = cData;
           
            if nargin > 3
                obj = obj.set(varargin);
            else
                % Then just plot
                graphPatch(obj);
            end
            
        end
                    
        varargout = set(varargin)
        
        varargout = get(varargin)
        
        function lineWidth = get.lineWidth(obj)
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
        end
        
        %{
        ---------------------------------------------------------------
        Delete the object
        ---------------------------------------------------------------
        %}
        function delete(obj)

            % Remove it form its parent
            if isa(obj.parent,'nb_axes')
                if isvalid(obj.parent)
                    obj.parent.removeChild(obj);
                end
            end

            if strcmpi(obj.deleteOption,'all')
                
                % Delete all the children of the object 
                for ii = 1:size(obj.children,2)

                    if ishandle(obj.children(ii))

                        delete(obj.children(ii))

                    end

                end
                
            end
           
        end
        
        %{
        -------------------------------------------------------------------
        Find the x-axis limits of this object
        -------------------------------------------------------------------
        %}
        function xlimit = findXLimits(obj)
        
            xlimit = [min(obj.xData),max(obj.xData)];
            
        end
            
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
            
            dataLow  = obj.yData;
            dataHigh = obj.yData;
            
            % Find the method to use
            if isa(obj.parent,'nb_axes')
                method = obj.parent.findAxisLimitMethod;
                if isa(obj.parent.parent,'nb_figure')
                    fig = obj.parent.parent.figureHandle;
                else
                    fig = obj.parent.parent;
                end
            else
                method = 4;
                fig    = get(obj.parent,'parent');
            end
            
            ylimit = nb_plotHandle.findLimitsAlgo(dataLow,dataHigh,method,fig);
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the visible property. This method should only be called from 
        the parent, when its visible property is set to 'off'
        -------------------------------------------------------------------
        %}
        function setVisible(obj)
            
            obj.visible = get(obj.parent,'visible');
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the legend info from this object. Used by the nb_legend class
        -------------------------------------------------------------------
        Output:
        
        - legendDetails : An nb_legendDetails object. If the 'legendInfo'
                          property is set to 'off'. It will return an empty
                          double, i.e. [];
        
        -------------------------------------------------------------------
        %}
        function legendDetails = getLegendInfo(obj)
            
            ld = nb_legendDetails();
            
            if strcmpi(obj.legendInfo,'on')
                
                ld.type               = 'patch';
                ld.patchColor         = obj.cData;             
                ld.patchDirection     = obj.direction;  
                ld.patchEdgeColor     = obj.edgeColor;   
                ld.patchEdgeLineWidth = obj.lineWidth;   
                ld.patchEdgeLineStyle = obj.lineStyle;   
                ld.patchFaceAlpha     = obj.faceAlpha;   
                ld.patchFaceLighting  = obj.faceLighting;
                ld.side               = obj.side;
                
            else
              
                ld = [];
                
            end
            
            legendDetails = ld;
            
        end
            
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Graph the patch
        -------------------------------------------------------------------
        %}
        function graphPatch(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                for ii = 1:length(obj.children)
                    delete(obj.children(ii));
                end
                obj.children = [];
            end
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,2) ~= 1
                if size(obj.xData,1) == 1
                    obj.xData = obj.xData';
                else
                    error([mfilename ':: The ''xData'' property has not only one column or only one row.'])
                end   
            end
            
            if size(obj.yData,2) ~= 1
                if size(obj.yData,1) == 1
                    obj.yData = obj.yData';
                else
                    error([mfilename ':: The ''yData'' property has not only one column or only one row.'])
                end 
            end
            
            if isempty(obj.cData)
                
                % Get the default color
                obj.cData = [51 51 51]/255;
                
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,2) ~= 3 || (size(obj.cData,1) ~= 1 && size(obj.cData,1) ~= 2)
                    error([mfilename ':: The ''cData'' property must be a 1x3 or a 2x3 (when doing shading) matrix with the rgb colors of the plotted data.'])
                end
                
            elseif ischar(obj.cData)
                
                if size(obj.cData,1) ~= 1 && size(obj.cData,1) ~= 2
                    error([mfilename ':: The char given by ''cData'' property can only have 1 or 2 (when doing shading) rows. Has: ' int2str(size(obj.cData,1)) '.'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end    
                
            elseif iscell(obj.cData)
                
                if length(obj.cData) ~= 1 && length(obj.cData) ~= 2
                    error([mfilename ':: The cellstr array given by ''cData'' property can only have length 1 or 2 (when doing shading). Has: ' int2str(length(obj.cData)) '.'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            else
                
                error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])    
                
            end
            
            if size(obj.cData,1) == 2
                obj.shaded = 1;
            end
            
            %--------------------------------------------------------------
            % Decide the parent (axes to plot on)
            %--------------------------------------------------------------
            if isempty(obj.parent)
                
                obj.parent = nb_axes();
                if strcmpi(obj.side,'right')
                     axh = obj.parent.plotAxesHandleRight;
                else
                    axh = obj.parent.plotAxesHandle;
                end
                
            else
                
                if isa(obj.parent,'nb_axes')
                    
                    if strcmpi(obj.side,'right')
                         axh = obj.parent.plotAxesHandleRight;
                    else
                        axh = obj.parent.plotAxesHandle;
                    end
                    
                else
                    axh = obj.parent;
                end
                
            end
            
            %--------------------------------------------------------------
            % Start plotting
            %--------------------------------------------------------------
            try
            
                if obj.shaded

                    % Find the color shading
                    colors = nb_patch.findShadingColors(obj.cData(1,:),obj.cData(2,:));

                    % Find the extra y-points needed for the shading
                    yValues = nb_patch.parseYDataForShading(obj.yData,obj.direction);

                    % Find the extra x-points needed for the shading
                    xValues = nb_patch.parseXDataForShading(obj.xData,obj.direction);

                    % Plot all the needed patches to make the shaded patch
                    hs = nan(1,255);
                    for ii = 1:255

                        colorTemp = colors(ii,:);
                        x         = xValues(:,ii);
                        y         = yValues(:,ii);
                        hs(ii)    = patch(x,y,colorTemp,...
                                          'parent',     axh,...
                                          'edgeColor',  'none',...
                                          'visible',    obj.visible,...
                                          'clipping',   obj.clipping);

                    end

                    % Plot the edges if the property 'edgeColor' is not 'none'
                    if ~strcmpi(obj.edgeColor,'none') || isnumeric(obj.edgeColor)
                        
                        if ischar(obj.edgeColor)
                            if strcmpi(obj.edgeColor,'same')
                                obj.edgeColor = obj.cData(1,:);
                            else
                                obj.edgeColor = nb_plotHandle.interpretColor(obj.edgeColor);
                            end
                        end
                        
                        if size(obj.xData,1) == 1
                            x = [obj.xData,obj.xData(1)];
                        else
                            x = [obj.xData;obj.xData(1)];
                        end
                        
                        if size(obj.yData,1) == 1
                            y = [obj.yData,obj.yData(1)];
                        else
                            y = [obj.yData;obj.yData(1)];
                        end

                        l = line(x,y,'color',       obj.edgeColor,...
                                     'lineStyle',   obj.lineStyle,...
                                     'lineWidth',   obj.lineWidth,...
                                     'parent',      axh,...
                                     'visible',     obj.visible,...
                                     'clipping',    obj.clipping);
                        
                        hs = [hs, l];

                    end

                    obj.children    = hs;
                    
                    % Set the renderer to fix a error with the 
                    % openGL renderer on some machines
                    if isa(obj.parent,'nb_axes')
                        if isa(obj.parent.parent,'nb_figure')
                            set(get(axh,'parent'),'renderer','painters')
                        else
                            set(get(get(axh,'parent'),'parent'),'renderer','painters')
                        end
                    else
                        h = get(axh,'parent');
                        if strcmpi(get(h,'type'),'figure')
                            set(h,'renderer','painters')
                        else
                            set(get(h,'parent'),'renderer','painters')
                        end
                    end

                else
                    
                    if ischar(obj.edgeColor)
                        if strcmpi(obj.edgeColor,'same')
                            obj.edgeColor = obj.cData(1,:);
                        elseif strcmpi(obj.edgeColor,'none')
                            % Do nothing
                        else
                            obj.edgeColor = nb_plotHandle.interpretColor(obj.edgeColor);
                        end
                    end

                    obj.children = patch(obj.xData,obj.yData,obj.cData,...
                                         'parent',       axh,...
                                         'edgeColor',    obj.edgeColor,...
                                         'faceAlpha',    obj.faceAlpha,...
                                         'faceLighting', obj.faceLighting,...
                                         'lineStyle',    obj.lineStyle,...
                                         'lineWidth',    obj.lineWidth,...
                                         'visible',      obj.visible,...
                                         'clipping',     obj.clipping);                   

                end
                
            catch Err
                
                % Delete all the made children so far
                if ~isempty(obj.children)
                    for ii = 1:length(obj.children)
                        delete(obj.children(ii));
                    end
                    obj.children = [];
                end
                
                if isa(obj.parent,'nb_axes')
                    obj.parent.deleteOption = 'all';
                    obj.parent.delete();
                else
                    delete(obj.parent)
                end
                
                % Try to give a good error message
                testProperties(obj);
                
                % Else throw the MATLAB error message
                rethrow(Err);
                
            end
            
            % Set the legend inforamtion of the MATLAB legend function
            if strcmpi(obj.legendInfo,'on')
                start = 2;
            else
                start = 1;
            end
            
            for ii = start:size(obj.children,2)
            
                set(get(get(obj.children(ii),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                
            end
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                    
                % Update the axes given the plotted data
                obj.parent.addChild(obj);

            end
            
        end
        
        %{
        -------------------------------------------------------------------
        If something goes wrong we can test if we can figure out the 
        problem
        -------------------------------------------------------------------
        %}
        function testProperties(obj)
            
            if size(obj.xData,1) ~= size(obj.yData,1)
                error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same length.'])
            end
            
%             if ~(isnumeric(obj.edgeColor) && size(obj.edgeColor,1) == 1 && size(obj.edgeColor,2) == 3)                            
%                 error([mfilename ':: The ''edgeColor'' must be given by a 1x3 double with the RGB colors.'])   
%             end
            
        end
        
    end
    
    %======================================================================
    % Static methods
    %======================================================================
    methods (Static=true)
        
        %{
        -------------------------------------------------------------------
        Find the colors of the shading in RGB values
        -------------------------------------------------------------------
        %}
        function colors = findShadingColors(color1,color2)
            
            colors      = zeros(256,3);
            colors(1,1) = color1(1);
            colors(1,2) = color1(2);
            colors(1,3) = color1(3);
            redGap      = color2(1) - colors(1,1);
            greenGap    = color2(2) - colors(1,2);
            blueGap     = color2(3) - colors(1,3);
            redStep     = redGap/255;
            greenStep   = greenGap/255;
            blueStep    = blueGap/255;
            for i = 2:256
                colors(i,1) = colors(1,1) + redStep*(i - 1);
                colors(i,2) = colors(1,2) + greenStep*(i - 1);
                colors(i,3) = colors(1,3) + blueStep*(i - 1);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Find all the x-points of the shading
        
        Temporary solution: Only squares are supported for all directions
                            of the shading
        -------------------------------------------------------------------
        %}
        function xValues = parseXDataForShading(xData,direction)
            
            if length(xData) ~= 4
                error([mfilename ':: It is only possible to add rectangular patches with shading.'])
            end
            
            if size(xData,2) == 4
                xData = xData';
            end
            
            switch direction
                
                case 'north'
                    
                    xv  = repmat(xData,1,256);
                    
                case 'south'
                    
                    xv  = repmat(xData,1,256);
                    xv  = flipdim(xv,2);
                    
                case 'west'
                    
                    xStep = (xData(3) - xData(1))/255;
                    x3    = [xData(1) repmat(xStep,1,255)];
                    x3    = cumsum(x3); 
                    x4    = x3(2:end);
                    x3    = x3(1:end-1);
                    xv    = [x3;x3;x4;x4];
                    xv    = flipdim(xv,2);
                    
                case 'east'
                    
                    xStep = (xData(3) - xData(1))/255;
                    x3    = [xData(1) repmat(xStep,1,255)];
                    x3    = cumsum(x3); 
                    x4    = x3(2:end);
                    x3    = x3(1:end-1);
                    xv    = [x3;x3;x4;x4];
                    
                otherwise
                    
                    error([mfilename ':: Unsupported direction ' direction])
                    
            end
            
            xValues = xv;
                    
        end
        
        %{
        -------------------------------------------------------------------
        Find all the y-points of the shading
        
        Temporary solution: Only squares are supported for all directions
                            of the shading
        -------------------------------------------------------------------
        %}
        function yValues = parseYDataForShading(yData,direction)
            
            if length(yData) ~= 4
                error([mfilename ':: It is only possible to add rectangular patches with shading.'])
            end
            
            if size(yData,2) == 4
                yData = yData';
            end
            
            switch direction
                
                case 'north'
                    
                    yStep = (yData(3) - yData(1))/255;
                    y3    = [yData(1) repmat(yStep,1,255)];
                    y3    = cumsum(y3); 
                    y4    = y3(2:end);
                    y3    = y3(1:end-1);
                    yv    = [y3;y4;y4;y3];
                    
                case 'south'
                    
                    yStep = (yData(3) - yData(1))/255;
                    y3    = [yData(1) repmat(yStep,1,255)];
                    y3    = cumsum(y3); 
                    y4    = y3(2:end);
                    y3    = y3(1:end-1);
                    yv    = [y3;y4;y4;y3];
                    yv    = flipdim(yv,2);
                 
                case 'west'
                    
                    yv = repmat(yData,1,256);
                    yv = flipdim(yv,2);
                     
                case 'east'
                    
                    yv = repmat(yData,1,256);
                    
                otherwise
                    
                    error([mfilename ':: Unsupported direction ' direction])
                    
            end
            
            yValues = yv;
            
        end
        
        
    end
        
end
