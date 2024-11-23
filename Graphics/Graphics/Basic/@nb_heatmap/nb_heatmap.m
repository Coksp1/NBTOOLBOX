classdef nb_heatmap < nb_plotHandle & nb_getable & nb_settable
% Syntax:
%     
% obj = nb_heatmap(data,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for making heatmap plot.
% 
% nb_heatmap(data) 
% nb_heatmap(xData,yData,'propertyName',propertyValue,...)
% handle = nb_heatmap(data,'propertyName',propertyValue,...)
%   
% The handle have set and get methods as all MATLAB graph handles. 
%     
% Constructor:
%     
%     obj = nb_heatmap(data,varargin)
%     
%     Input:
% 
%     - data     : The xData of the plotted data. As a N x M double.
%                         
%     - varargin : ...,'propertyName',propertyValue,...
%     
%     Output
% 
%     - obj      : An object of class nb_bar
%     
%     Examples:
% 
%     obj = nb_heatmap(magic(5)); 
%     obj = nb_heatmap(magic(5),'propertyName',propertyValue,...)
%     obj = nb_heatmap(magic(5),'propertyName',propertyValue,...)
%     
% See also: 
% heatmap, nb_axes     
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties(SetAccess=protected)

        % All the handles of the bar plot.
        children              = [];  
        
        % {'off'} : Not included in the legend. 'on' : included in 
        % the legend
        legendInfo            = 'off';  
        
        % {'left'} Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default)
        side                = 'left';
        
        % The xData of the plotted data. Must be of size; 
        % size(yData,1) x 1 or 1 x size(yData,1)
        xData                 = [];      
        
        % The yData of the plot. The columns are counted as 
        % seperate variables.
        yData                 = []; 
        
    end

    properties
        
        % Color of the plotted data. A matrix; 
        % size(yData,2) x 3 (RGB color). Or a cellstr
        % with the color names. (With size 1 x size(yData,2))
        cData                 = []; 
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption          = 'only'; 
        
        % {'normal'} | 'italic' | 'oblique'
        fontAngle             = 'normal';
        
        % The font name used on the text of the axes.
        fontName              = 'arial';  
        
        % The font size used on the text of each box of the heatmap.
        % Default is 12.
        fontSize              = 12;   
        
        % {'points'} | 'normalized' | 'inches'    
        % | 'centimeters' | 'pixels'
        % 
        % Font size units. MATLAB uses this 
        % property to determine the units used 
        % by the fontSize property.
        % 
        % normalized - Interpret FontSize as a 
        % fraction of the height of the parent  
        % axes. When you resize the axes, 
        % MATLAB modifies the screen 
        % fontSize accordingly.
        % 
        % pixels, inches, centimeters, and  
        % points: Absolute units. 1 point = 
        % 1/72 inch.
        fontUnits             = 'points'; 
        
        % The font weight used on the text of the axes. Only the 
        % x-tick and y-tick labels
        fontWeight            = 'normal';
        
        % Interpret TeX instructions. Must be a string. 'latex' |
        % {'tex'} | 'none'.
        interpreter           = 'tex';
        
        % Sets the color of the boxes of the heatmap with missing
        % observations.
        missingColor          = [0 0 0];
        
        % The precision on the displayed numbers of the heatmap E.g. 
        % '%6.6f' or 4 (number of digits).
        precision             = 4;
        
        % Set elements to true to reverse the color scale of the matching
        % columns. As a logical vector with same size as cData!
        reverseScale          = [];
        
        % Set to true to standardise each columns of the input data. This
        % will make the scaled colors scale individually for each column.
        % Default is not to standardise.
        % Caution: Even if set to true, the displayed data (text) is not
        % standardised!
        stdise                = false;
        
        % Color of text. Must be of size; 1 x 3. With the RGB 
        % colors. Or a string with the name of the color. See the 
        % method interpretColor of the nb_plotHandle class 
        % for more on the supported color names.
        textColor             = [0 0 0];
        
        % Text orientation. Determines the orientation of the 
        % text string. Specify values of rotation in degrees 
        % (positive angles cause counterclockwise rotation). Must 
        % be a scalar. Default is 0.
        textRotation          = 0;
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'.
        visible               = 'on';
          
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        type = 'patch';
        
    end
    
    %======================================================================
    % Methods of the class
    %======================================================================
    methods
        
        function set.cData(obj,value)
            if ~isnumeric(value)
                error('The cData property must must be set to a double matrix.')
            end
            obj.cData = value;
        end       
        
        function set.deleteOption(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The deleteOption property must be'...
                                 ' set to a one line character array.'])
            end
            obj.deleteOption = value;
        end
        
        function set.fontAngle(obj,value)
            if ~nb_isOneLineChar(value)
                error('The fontAngle property must be set to a one line character array.')
            end
            obj.fontAngle = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value)
                error('The fontName property must be set to a one line character array.')
            end
            obj.fontName = value;
        end
        
        function set.fontSize(obj,value)
            if ~nb_isScalarNumber(value)
                error('The fontSize property must be set to a double.')
            end
            obj.fontSize = value;
        end
        
        function set.fontUnits(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'points',...
                    'normalized'...
                    'inches','centimeters','pixels'},value))
                error(['The fontUnits property must be'...
                    ' set to either ''points'', ''normalized'''...
                    ' ''inches'', ''centimeters'' or ''pixels''.'])
            end
            if ~isempty(obj.children) %#ok<MCSUP>
                for ii = 1:length(obj.children) %#ok<MCSUP>
                    if ishandle(obj.children(ii)) && strcmpi(get(obj.children(ii),'type'),'text')  %#ok<MCSUP>
                        set(obj.children(ii),'fontUnits',value); %#ok<MCSUP>
                        obj.fontSize = get(obj.children(ii),'fontSize'); %#ok<MCSUP>
                    end
                end
                obj.children = []; %#ok<MCSUP>
            end
            obj.fontUnits = value;
        end
        
        function set.fontWeight(obj,value)
            if ~nb_isOneLineChar(value)
                error('The fontWeight property must be set to a one line character array.')
            end
            obj.fontWeight = value;
        end
        
        function set.precision(obj,value)
            if ~(nb_isScalarInteger(value) || nb_isOneLineChar(value))
                error(['The precision property must beset to either a ',...
                    'scalar integer of a one line char.'])
            end
            obj.precision = value;
        end
        
        function set.missingColor(obj,value)
            if ~nb_isColorProp(value)
                error(['The missingColor property must beset a valid ',...
                    'property value (RGB vector or a NB toolbox predefined name).'])
            end
            obj.missingColor = value;
        end
        
        function set.reverseScale(obj,value)
            if isempty(value)
                obj.reverseScale = [];
                return 
            end
            if ~(islogical(value) && isvector(value))
                error('The reverseScale property must must be set to a logical vector or empty.')
            end
            obj.reverseScale = value;
        end  
        
        function set.stdise(obj,value)
            if ~nb_isScalarLogical(value)
                error(['The stdise property must beset to a ',...
                    'scalar logical.'])
            end
            obj.stdise = value;
        end
        
        function set.textColor(obj,value)
            if ~nb_isColorProp(value)
                error(['The textColor property must beset a valid ',...
                    'property value (RGB vector or a NB toolbox predefined name).'])
            end
            obj.textColor = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The visible property must be'...
                                 ' set to either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
        
        function obj = nb_heatmap(data,varargin)
            
            if nargin == 0
                return;
            end
            
            if nargin < 2
                if nargin == 1
                    obj.cData = data;
                else
                    obj.cData = magic(5);
                end
            else
                if ~isnumeric(data)
                    obj.cData = magic(5);
                    varargin  = [data,varargin];
                else
                    obj.cData = data;
                end 
            end
            obj.xData = 1:size(obj.cData,2);
            obj.yData = 1:size(obj.cData,1);
            
            if nargin > 1
                obj.set(varargin);
            else
                % Then just plot
                plot(obj);
            end
            
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
            
            % Delete all the children of the object 
            deleteChildren(obj);
             
        end
        
        %{
        -------------------------------------------------------------------
        Find the x-axis limits of this object
        -------------------------------------------------------------------
        %}
        function xlimit = findXLimits(obj)
        
            xlimit    = [min(obj.xData),max(obj.xData)];
            xlimit(1) = xlimit(1) - 0.5;
            xlimit(2) = xlimit(2) + 0.5;
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
            
            ylimit    = [min(obj.yData),max(obj.yData)];
            ylimit(1) = ylimit(1) - 0.5;
            ylimit(2) = ylimit(2) + 0.5;
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the visible property of this handle and all the children 
        (Without replotting) This method should only be called from the 
        parent, when its visible property is set to 'off'
        -------------------------------------------------------------------
        %}
        function setVisible(obj)
            
            obj.visible = get(obj.parent,'visible');
            obj.baseline.setVisible();
            for ii = 1:size(obj.children,2)
                obj.children(ii).setVisible();
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Get the legend info from this object. Used by the nb_legend class
        -------------------------------------------------------------------
        Output:
        
        - legendDetails : An 1 x M array of nb_legendDetails, where M is 
                          the number of children of this object which has 
                          it 'legendInfo' property set to 'on'. If this 
                          object property 'legendInfo' is set to 'off' 
                          this method will return [].
        
        -------------------------------------------------------------------
        %}
        function legendDetails = getLegendInfo(obj) %#ok<MANU>
            legendDetails = [];
        end
  
    end
    
    methods(Hidden=true)
        
        function imData = getImageData(obj)
            imData = obj.cData;
            if obj.stdise
                imData = (imData - mean(imData,1,'omitnan'))./std(imData,0,1,'omitnan');
            end
            if ~isempty(obj.reverseScale)
                if size(imData,2) ~= length(obj.reverseScale)
                    error(['The reverseScale input must have length equal ',...
                        'to the number of columns of the data to plot (',...
                        int2str(size(imData,2)) ')!']);
                end
                for ii = 1:size(imData,2)
                    if obj.reverseScale(ii)
                        if obj.stdise
                            imData(:,ii) = -imData(:,ii);
                        else
                            mImData      = mean(imData(:,ii),1,'omitnan');
                            imData(:,ii) = mImData - (imData(:,ii) - mImData);
                        end
                    end
                end
            end
            
        end
        
        function deleteChildren(obj)
            
            if ~isempty(obj.children)
                if ishandle(obj.children)
                    delete(obj.children);
                end
                obj.children = [];
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        function update(obj)
            plot(obj);
        end
        
        function plot(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            deleteChildren(obj);
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,2) ~= 1
                if size(obj.xData,1) == 1
                    obj.xData = obj.xData';
                else
                    error('The ''xData'' property has not only one column or only one row.')
                end   
            end
            
            if size(obj.yData,2) ~= 1
                if size(obj.yData,1) == 1
                    obj.yData = obj.yData';
                else
                    error('The ''yData'' property has not only one column or only one row.')
                end 
            end
            
            if ~isnumeric(obj.cData)
                error(['The property ''cData'' doesn''t support input of class ' class(obj.cData)])    
            end
            
            if size(obj.yData,1) ~= size(obj.cData,1)
                error('The ''yData'' and the ''cData'' properties does not match.')
            end
             
            if size(obj.xData,1) ~= size(obj.cData,2)
                error('The ''xData'' and the ''cData'' properties does not match.')
            end
            
            %----------------------------------------------------------
            % Decide the parent (axes to plot on)
            %----------------------------------------------------------
            if isempty(obj.parent)
                obj.parent = nb_axes();
            end
            if isa(obj.parent,'nb_axes')
                axh = obj.parent.plotAxesHandle;
            else
                axh = obj.parent;
            end
            if isempty(get(obj.parent,'colorMap'))
                cMap = nb_axes.defaultColorMap();
                set(obj.parent,'colorMap',cMap);
            end
            
            % Create a heatmap-like display using imagesc
            imData = getImageData(obj);
            h      = imagesc(flip(imData,1),'parent',axh,'xData',obj.xData,'yData',obj.yData);
            
            if isa(obj.parent,'nb_axes')
                set(obj.parent,'XTick', obj.xData, 'YTick', obj.yData,...
                    'yTickRight', obj.yData, 'tickLength', [0,0]);
                cMap = getColorMap(obj.parent);
            else
                set(obj.parent,'XTick', obj.xData, 'YTick', obj.yData, ...
                    'tickLength', [0,0]);
                cMap = get(obj.parent,'colorMap');
            end
            
            set(axh,'colorMap',cMap);
            
            % Desired display values (for illustration purposes)
            displayData = nb_double2cell(obj.cData,obj.precision);

            % Overlay the desired display values on top of the heatmap cells
            if ischar(obj.textColor)
                textC = nb_plotHandle.interpretColor(obj.textColor);
            else
                textC = obj.textColor;
            end
            t = nb_gobjects(size(obj.cData, 1),size(obj.cData, 2));
            for jj = 1:size(obj.cData, 2)
                for ii = 1:size(obj.cData, 1)
                    t(ii,jj) = text(jj, size(obj.cData, 1) - ii + 1, displayData{ii, jj}, ...
                        'fontAngle', obj.fontAngle,...
                        'fontName', obj.fontName,...
                        'fontUnits', obj.fontUnits,...
                        'fontSize', obj.fontSize,...
                        'fontWeight', obj.fontWeight,...
                        'interpreter', obj.interpreter,...
                        'parent', axh,...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', ...
                        'color', textC); % You can set the text color as needed
                end
            end
            
            % Create lines around boxes
            xlimit = findXLimits(obj);
            ylimit = findYLimits(obj);
            l      = nb_gobjects(1,size(obj.cData, 1) + size(obj.cData, 2) - 2);
            for ii = 1:size(obj.cData, 1)-1
                l(ii) = line(xlimit, [ii+0.5,ii+0.5], ...
                    'parent', axh,...
                    'lineStyle','-',...
                    'lineWidth',get(axh,'lineWidth'),...
                    'color',[0,0,0]);
            end
            for jj = 1:size(obj.cData, 2)-1
                l(jj+size(obj.cData, 1)-1) = line([jj+0.5,jj+0.5], ylimit, ...
                    'parent', axh,...
                    'lineStyle','-',...
                    'lineWidth',get(axh,'lineWidth'),...
                    'color',[0,0,0]);
            end
            
            % Do we have any missing observations?
            if ischar(obj.textColor)
                missC = nb_plotHandle.interpretColor(obj.missingColor);
            else
                missC = obj.missingColor;
            end
            numM = sum(isnan(imData(:)));
            m    = nb_gobjects(1,numM);
            kk   = 1;
            for jj = 1:size(obj.cData, 2)
                for ii = 1:size(obj.cData, 1)
                    if isnan(obj.cData(ii, jj))
                        x     = jj;
                        y     = size(obj.cData, 1) - ii + 1;
                        xx    = [x+0.5,x+0.5,x-0.5,x-0.5];
                        yy    = [y-0.5,y+0.5,y+0.5,y-0.5];
                        m(kk) = patch(xx,yy,missC,...
                            'parent', axh,...
                            'lineStyle','none');
                        kk = kk + 1;
                    end
                end
            end
            
            obj.children = [h,t(:)',l,m];
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                % Update the axes given the plotted data
                obj.parent.addChild(obj);
            end
            
        end
        
    end
    
    %======================================================================
    % Static methods
    %======================================================================
    methods (Static=true)
       
           
    end
    
end
        
