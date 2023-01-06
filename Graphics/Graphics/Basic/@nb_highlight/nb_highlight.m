classdef nb_highlight < nb_plotHandle
% Syntax:
%     
% obj = nb_highlight(xData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% A class for making highlighted colored areas in the background of
% a plot
%     
% The parent of this axes must be a nb_axes handle.
%     
% This colored background will automatically adjust to changes in 
% the y-axis limits.
%     
% Constructor:
%     
%     obj = nb_highlight(xData,varargin)
%     
%     Input:
% 
%     - xData    : A 1 x 2 double with the x-axis limits of the 
%                  highlighted area.
%
%     Optional input:
% 
%     - varargin : ...,'propertyName',propertyValue,...  
%     
%     Output
% 
%     - obj      : An object of class nb_highlight
%     
%     Examples:
% 
%     nb_highlight(xData)
%     nb_highlight(xData,'propertyName',propertyValue,...)
%     handle = nb_highlight(xData,'propertyName',propertyValue,...)
%    
% See also:
% nb_patch
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties(SetAccess=protected)
        
        % The child of this handle. As a nb_patch handle.
        children            = [];
        
    end
    properties
       
        % Must be a 1 x 3 double with the RGB colors or
        % a string with the color name. See the 
        % method interpretColor of the nb_plotHandle 
        % class for more on the supported color names.
        cData               = 'light blue'; 
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption        = 'only';
        
        % {'off'} : Not included in the legend. 'on' : included in 
        % the legend  
        legendInfo          = 'on';     
        
        % Sets the visibility of the radar plot. {'on'} | 'off'.
        visible             = 'on';         
        
        % A 1 x 2 double with the x-axis limits of the highlighted 
        % area, or a logical vector with size N x 1. In the case xData
        % is given as a logical vector it will highlight the periods where
        % the elements are true.
        xData               = [];           
        
    end
    
    %======================================================================
    % Protected properties of the object
    %======================================================================
    properties (Access=protected)
        
        type            = 'patch';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function set.cData(obj,value)
            if ~nb_isColorProp(value,true)
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
        
       function set.xData(obj,value)
            if ~isa(value,'double') 
                error([mfilename ':: The xData property must be'...
                                 ' given as double.'])
            end
            obj.xData = value;
        end       
        

        function obj = nb_highlight(xData,varargin)
            
            if nargin < 1
                xData = [0.25; 0.75];
            end
            
            if islogical(xData)
               loc = find(xData(:));
               if isempty(loc)
                   obj = nb_highlight.empty();
                   return
               end
               d     = [1;diff(loc)];
               b     = find(d > 1);
               num   = size(b,1) + 1;
               high  = cell(1,num);
               start = 1;
               for ii = 1:num-1
                   high{ii} = nb_highlight([loc(start),loc(b(ii)-1)],varargin{:});
                   start    = b(ii);
               end
               high{end} = nb_highlight([loc(start),loc(end)],varargin{:});
               obj       = [high{:}];
               return
            end
            
            % Assign properties
            obj.xData = xData;
            
            if nargin > 2
                obj.set(varargin{:});
            else
                obj.parent = nb_axes();
                
                % Then add it to its parent, where it is plotted
                addToAxes(obj);
            end
            
        end
        
        varargout = set(varargin)
        
        varargout = get(varargin)
        
        %{
        ---------------------------------------------------------------
        Delete the object
        ---------------------------------------------------------------
        %}
        function delete(obj)

            % Remove it form its parent
            if isa(obj.parent,'nb_axes')
                if isvalid(obj.parent)
                    obj.parent.removeHighlighted(obj);
                end
            end

            if strcmpi(obj.deleteOption,'all')
                
                % Delete all the children of the object 
                if isvalid(obj.children)

                    obj.children.deleteOption = 'all';
                    delete(obj.children)

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
            
            obj.visible          = get(obj.parent,'visible');
            obj.children.visible = obj.visible;
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the vertical line given changes in the parent (The axes it 
        is plotted on)
        -------------------------------------------------------------------
        %}
        function update(obj)
            
            % Plot the vertical line, given changes in the parent handle
            plotHighlight(obj)
            
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
        Add the object to its parent
        -------------------------------------------------------------------
        %}
        function addToAxes(obj)
            
            obj.parent.addHighlighted(obj);
            
        end
        
        %{
        -------------------------------------------------------------------
        Plot the highlighted area
        -------------------------------------------------------------------
        %}
        function plotHighlight(obj)
            
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
            sData = size(obj.xData);
            
            if sData(1) == 1 && sData(2) == 2
                obj.xData = obj.xData';
            elseif not(sData(2) == 1 && sData(1) == 2)
                error([mfilename ':: The ''xData'' property must be a 1x2 double or a 2x1 double. With the x-axis limits of the highlighted area.'])
            end
            
            if ischar(obj.cData) 
                
                obj.cData = nb_plotHandle.interpretColor(obj.cData);
                
                if size(obj.cData,1) ~= 1
                    error([mfilename ':: The ''cData'' property must be a string with color name or a 1x3 double with the RGB color.'])
                end
                
            elseif isnumeric(obj.cData)
                
                if size(obj.cData,1) ~= 1 || size(obj.cData,2) ~= 3
                    error([mfilename ':: The ''cData'' property must be a string with color name or a 1x3 double with the RGB color.'])
                end
                
            elseif iscell(obj.cData)
                
                if length(obj.cData) ~= 1
                    error([mfilename ':: If the ''cData'' property is a cell, it could only contain 1 element.'])
                end
                
                if ischar(obj.cData{1})
                    
                    obj.cData = nb_plotHandle.interpretColor(obj.cData);
                
                    if size(obj.cData,1) ~= 1
                        error([mfilename ':: The ''cData'' property must be a string with color name or a 1x3 double with the RGB color.'])
                    end
                    
                elseif isnumeric(obj.cData{1})
                    
                    obj.cData = obj.cData{1};
                    
                    if size(obj.cData,1) ~= 1 || size(obj.cData,2) ~= 3
                        error([mfilename ':: The ''cData'' property must be a string with color name or a 1x3 double with the RGB color.'])
                    end
                    
                else
                    error([mfilename ':: The ''cData'' property must be a string with color name or a 1x3 double with the RGB color.'])
                end
                
            else
                error([mfilename ':: The ''cData'' property must be a string with color name or a 1x3 double with the RGB color.'])
            end
                
            %--------------------------------------------------------------
            % Decide the parent (axes to plot on)
            %--------------------------------------------------------------
            axH = obj.parent.plotAxesHandle;
            axS = obj.parent.shadingAxes;
            
            %--------------------------------------------------------------
            % Get the limits
            %--------------------------------------------------------------
            xLimH = get(axH,'xLim');
            xLimS = get(axS,'xLim');
            yLimS = get(axS,'yLim');
            
            if diff(obj.xData) == 0
                
                xNormalization = (diff(xLimS))/(diff(xLimH));
                x              = nan(2,1);
                x(1)           = xLimS(1) + (obj.xData(1) - xLimH(1))*xNormalization;
                x(2)           = xLimS(1) + (obj.xData(2) - xLimH(1))*xNormalization;

                %--------------------------------------------------------------
                % Start plotting (Plotting on the background axes)
                %--------------------------------------------------------------
                obj.children = nb_line(x,yLimS,...
                         'cData',   obj.cData,...
                         'parent',  axS,...
                         'visible', obj.visible);
                
            else
            
                x              = nan(4,1);
                y              = nan(4,1);
                xNormalization = (diff(xLimS))/(diff(xLimH));
                x(1:2)         = xLimS(1) + (obj.xData(1) - xLimH(1))*xNormalization;
                x(3:4)         = xLimS(1) + (obj.xData(2) - xLimH(1))*xNormalization;
                y(1:3:4)       = yLimS(1);
                y(2:3)         = yLimS(2);

                %--------------------------------------------------------------
                % Start plotting (Plotting on the background axes)
                %--------------------------------------------------------------
                obj.children = nb_patch(x,y,obj.cData,...
                         'parent',      axS,...
                         'lineStyle',   'none',...
                         'visible',     obj.visible);
                
            end
                 
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
    
end
