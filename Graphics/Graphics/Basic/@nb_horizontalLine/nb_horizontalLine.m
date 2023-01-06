classdef nb_horizontalLine < nb_plotHandle
% Syntax:
%     
% obj = nb_horizontalLine(yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for making horizontal lines which spans all of 
% the x-axis.
% 
% If the parent is a nb_axes object:
%     
% - The line will automatically update the length of the line,
%   so it spans all the x-axis.
%  
% If the parent is a MATLAB axes handle (object):
%     
% - The line will not update itself automatically and you need
%   to use the update() method of the object to make it fit to 
%   the axes handle (If it is changed)
%     
% Constructor:
%     
%     obj = nb_horizontalLine(yData,varargin)
%     
%     Input:
% 
%     - yData    : The y-axis value to place the horizontal line
% 
%     - varargin : ...,'propertyName',propertyValue,...
%     
%     Output
% 
%     - obj      : an object of class nb_horizontalLine
%     
%     Examples:
% 
%     nb_horizontalLine(yData)
%     obj = nb_horizontalLine(yData)
%     obj = nb_horizontalLine(yData,'propertyName',...
%                               propertyValue,...)
%     
% See also:
% nb_line
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties(SetAccess=protected)
                
        % The children of this object. As an nb_line object.
        children            = [];    
        
    end

    properties
       
        % The color data of the line plotted. Must be 
        % of size; 1 x 3 with the RGB colors or a 
        % string with the color name.
        cData               = [];       
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.  
        deleteOption        = 'only'; 
        
        % {'off'} : Not included in the legend. 'on' : 
        % included in the legend
        legendInfo          = 'off';
        
        % The line style of the plotted data. Either a 
        % string or a cell array with size as the 
        % number of lines to be plotted. {'-'} | '--' |
        % '---' | ':' | '-.' | 'none'
        lineStyle           = '-';
        
        % The line width of the plotted data. Must be a scalar. 
        % Default is 1.
        lineWidth           = 1;   
        
        % The markers of the lines. Either a string or 
        % a cell array with size as the number of lines 
        % to be plotted. See marker property of the 
        % MATLAB line function for more on the options 
        % of this property
        marker              = 'none';      
        
        % A 1x3 double with the RGB colors | 'none' | 
        % {'auto'} | a string with the color name.
        markerEdgeColor     = 'auto';       
        
        % A 1x3 double with the RGB colors | 'none' | 
        % {'auto'} | a string with the color name.
        markerFaceColor     = 'auto';  
        
        % Size of the markers. Must be a integer. Default is 9.
        markerSize          = 9;            
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default) 
        side                = 'left'; 
        
        % Sets the visibility of the plotted lines. {'on'} | 'off'.
        visible             = 'on';      
        
        % A scalar with the y-axis value for where to place the  
        % horizontal line.
        yData               = [];           
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        type = 'line';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
         
        function set.cData(obj,value)
            if ~nb_isColorProp(value,1)
                error([mfilename ':: The cData property must'...
                    ' must have dimension size'...
                    ' 1 x 3 with the RGB'...
                    ' colors or a one line character array'...
                    ' with the color name.'])
            end
            obj.cData = value;
        end
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.legendInfo(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The legendInfo property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The visible property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
        
        function set.lineStyle(obj,value)
            if ~nb_islineStyle(value,1)
                error([mfilename ':: The lineStyle property must be'...
                    ' a one line char or a cellstring with the line'...
                    ' linestyle with size size(xData,2).'])
            end
            obj.lineStyle = value;
        end
        
        function set.lineWidth(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The lineWidth property must be'...
                    ' set to a scalar double.'])
            end
            obj.lineWidth = value;
        end
        
        function set.marker(obj,value)
            if ~nb_ismarker(value,1)
                error([mfilename ':: The marker property must be set to'...
                    ' a valid marker value.'])
            end
            obj.marker = value;
        end
        
        function set.markerEdgeColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The markerEdgeColor property must'...
                    ' must have dimension size'...
                    ' 1 x 3 with the RGB colors'...
                    ' or a one line character array with'...
                    ' ''none'' or ''auto''.'])
            end
            obj.markerEdgeColor = value;
        end
        
        function set.markerSize(obj,value)
            if ~nb_isScalarInteger(value)
                error([mfilename ':: The markerSize property must be'...
                                 ' given as an integer.'])
            end
            obj.markerSize = value;
        end             
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename ':: The side property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.side = value;
        end          
        
        function set.markerFaceColor(obj,value)
            if ~nb_isColorProp(value,1) 
                error([mfilename ':: The markerFaceColor property must'...
                                 ' must have dimension size'...
                                 ' 1 x 3 with the RGB colors'...
                                 ' or a one line character array with'...
                                 ' ''none'' or ''auto''.'])
            end
            obj.markerFaceColor = value;
        end        
        
        function set.yData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The yData property must be'...
                    ' given as double.'])
            end
            obj.yData = value;
        end
        
        function obj = nb_horizontalLine(yData,varargin)
            
            if nargin == 0
                
                % Default is a zero line
                obj.yData = 0;
                
                % Construct the default parent
                obj.parent = nb_axes;

                % Add the object to its parent, where it will be
                % plotted
                addToAxes(obj)
                
            elseif nargin >= 1
                
                if isscalar(yData) || isempty(yData)
                    obj.yData = yData;
                else
                    error([mfilename ':: The input ''yData'' must be a scalar.'])
                end
            
                if nargin > 1
                    
                    % Use the set method to interpreter the optional inputs
                    obj.set(varargin{:});
                    
                else
                    
                    % Construct the default parent
                    obj.parent = nb_axes;
                    
                    % Add the object to its parent, where it will be
                    % plotted
                    addToAxes(obj);
                    
                end
                
            end
            
        end

        varargout = set(varargin)
        
        varargout = get(varargin)
        
        function lineWidth = get.lineWidth(obj)
           lineWidth = nb_scaleLineWidth(obj,obj.lineWidth); 
        end
        
        function markerSize = get.markerSize(obj)
           markerSize = nb_scaleLineWidth(obj,obj.markerSize); 
        end
        
        %{
        -------------------------------------------------------------------
        Delete the object
        -------------------------------------------------------------------
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
        Set the visible property. This method should only be called from 
        the parent, when its visible property is set to 'off'
        -------------------------------------------------------------------
        %}
        function setVisible(obj)
            
            obj.visible = get(obj.parent,'visible');
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the horizontal line given changes in the parent (The axes it 
        is plotted on)
        -------------------------------------------------------------------
        %}
        function update(obj)
            
            % Plot the horizontal line, given changes in the parent handle
            plotHorizontalLine(obj)
            
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
            
            legendDetails = [];
            
            if strcmpi(obj.legendInfo,'on')
                
                legendDetails = obj.children.getLegendInfo();
                
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Add the object to its parent (Only if the parent is an object of 
        class nb_axes)
        -------------------------------------------------------------------
        %}
        function addToAxes(obj)
            
            obj.parent.addChild(obj);
            
        end
        
        %{
        -------------------------------------------------------------------
        Plot the horizontal line
        -------------------------------------------------------------------
        %}
        function plotHorizontalLine(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                obj.children.deleteOption = 'all';
                delete(obj.children);
                obj.children = [];
            end
            
            %--------------------------------------------------------------
            % Return if there is nothing to plot
            %--------------------------------------------------------------
            if isempty(obj.yData)
                return;
            end
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if isempty(obj.cData)
                
                % Get the default color
                obj.cData = [51 51 51]/255;
                
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,2) ~= 3 || size(obj.cData,1) ~= 1
                    error([mfilename ':: The ''cData'' property must be a 1x3 matrix with the rgb colors of the plotted data.'])
                end
                
            elseif ischar(obj.cData)
                
                if size(obj.cData,1) ~= 1
                    error([mfilename ':: The char given by ''cData'' property has not same number of rows (' int2str(size(obj.cData,1)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end    
                
            elseif iscell(obj.cData)
                
                if length(obj.cData) ~= 1
                    error([mfilename ':: The cellstr array given by ''cData'' property has not same length (' int2str(length(obj.cData)) ') as the property ''yData'' has columns. (' int2str(size(obj.yData,2)) ')'])
                else
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                end
                
            else
                
                error([mfilename ':: The property ''cData'' doesn''t support input of class ' class(obj.cData)])
                
            end
            
            %--------------------------------------------------------------
            % Construct the plotting data given the parent x-axis limits
            %--------------------------------------------------------------
            y = [obj.yData,obj.yData];
            x = get(obj.parent,'xLim');
            
            %--------------------------------------------------------------
            % Decide the parent (axes to plot on)
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                if strcmpi(obj.side,'right')
                    axh = obj.parent.plotAxesHandleRight;
                else
                    axh = obj.parent.plotAxesHandle;
                end
            else
                axh = obj.parent;
            end
            
            %--------------------------------------------------------------
            % Start the plotting
            %--------------------------------------------------------------
            obj.children = nb_line(x,y,...
                                   'cData',            obj.cData,...
                                   'legendInfo',       obj.legendInfo,...
                                   'lineStyle',        obj.lineStyle,...
                                   'lineWidth',        obj.lineWidth,...
                                   'marker',           obj.marker,...
                                   'markerEdgeColor',  obj.markerEdgeColor,...
                                   'markerFaceColor',  obj.markerFaceColor,...
                                   'markerSize',       obj.markerSize,...
                                   'parent',           axh,...
                                   'side',             obj.side,...
                                   'visible',          obj.visible);
                            
            
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
    
end
