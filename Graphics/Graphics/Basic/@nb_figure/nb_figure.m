classdef nb_figure < handle
% Syntax:
%     
% obj = nb_figure(varargin)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% This is a object representing a MATLAB figure. This class extends 
% the MATLAB figure class.
%   
% Through the figureHandle property you have all the MATALB
% functionalities, but you can also store nb_axes objects (not 
% the MATLAB class axes), which again can store nb_bar, nb_pie, 
% nb_radar, nb_plot, nb_area, nb_patch, nb_scatter and nb_plotComb 
% objects.
% 
% This class makes it also possible to add a title for the whole 
% figure which will be placed above all the children (axes 
% including text objects). And it makes it possible to add a footer
% to the figure below all the children (axes including text 
% objects) of the figure. Set the properties figureTitle and 
% footer respectively.     
%     
% These classes makes it more easy to create nice graphics.
%     
% Constructor:
%     
%     obj = nb_figure(varargin)
%     
%     Input: 
% 
%     - varargin : ...,'propertyName',propertyValue,...
%     
%     Output
% 
%     - obj      : An object of class nb_figure
%     
%     Examples:
% 
%     nb_figure
%     obj = nb_figure()
%     obj = nb_figure('propertyName',propertyValue,...)
%     
% See also:  
% figure      
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(SetAccess=protected)
           
        % The children of the figure. Must be of class nb_axes.
        children     = [];    
        
    end

    properties
        
        % {'all'} | 'only'. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption = 'only'; 

        % A MATLAB figure handle.
        figureHandle = [];          
        
        % The title of the figure. Placed above all the figure axes 
        % as an nb_figureTitle object.
        figureTitle  = [];  
        
        % The footer placed below all the figure axes as an 
        % nb_footer object.
        footer       = [];  
      
        % User data
        userData     = [];
        
    end
    
    events
       
        keyPress
        keyRelease
        mouseDown
        mouseUp
        mouseMove
        resized 
          
    end
      
    methods
   
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        
        function set.figureHandle(obj,value)
            if ~nb_isFigure(value) && ~isempty(value)
                error([mfilename '::  The figureHandle property must be'...
                    ' given as ha MATLAB figure handle or empty.'])
            end
            obj.figureHandle = value;
        end
        
        function set.figureTitle(obj,value)
            if ~isa(value,'nb_figureTitle') && ~isempty(value)
                error([mfilename '::  The figureTitle property must be'...
                    ' given as an nb_figureTitle object or empty.'])
            end
            obj.figureTitle = value;
        end        
        
        function set.footer(obj,value)
            if ~isa(value,'nb_footer') && ~isempty(value)
                error([mfilename '::  The footer property must be'...
                    ' given as an nb_footer object or empty.'])
            end
            obj.footer = value;
        end    
        
        function set.userData(obj,value)
            if ~isa(value,'double') && ~isempty(value)
                error([mfilename '::  The userData property must be'...
                    ' given as a double.'])
            end
            obj.userData = value;
        end          
        
        function obj = nb_figure(varargin)
        % Constructor of the nb_figure class
        
            % Construct a MATLAB figure handle
            f = figure(varargin{:});
            
            % Set callback function when figure resizes 
            %
            % We want that the nb_legend objects to not to resize
            % when the figure does
            set(f,'resizeFcn',              @obj.resizeCallback,...
                  'WindowButtonMotionFcn',  @obj.mouseMoveCallback,...
                  'keyPressFcn',            @obj.keyPressCallback,...
                  'keyReleaseFcn',          @obj.keyReleaseCallback,...
                  'WindowButtonDownFcn',    @obj.mouseDownCallback,...
                  'WindowButtonUpFcn',      @obj.mouseUpCallback,...
                  'userData',               obj);
            
            % Assign the MATLAB figure object to the nb_figure 
            % object
            obj.figureHandle = f;

        end
        
        varargout = set(varargin)
        varargout = get(varargin)

        %{
        -------------------------------------------------------------------
        Delete the nb_figure object
        -------------------------------------------------------------------
        %}
        function delete(obj)
            
            % Delete all the nb_axes objects of the object 
            for ii = 1:size(obj.children,2) 
                if isvalid(obj.children(ii))
                    % Set the delete option for the children
                    obj.children(ii).deleteOption = obj.deleteOption;
                    
                    % Then delete
                    delete(obj.children(ii))
                end 
            end
            
            if strcmpi(obj.deleteOption,'all')
                % Delete the MATLAB figure handle
                delete(obj.figureHandle);
            else
                if ishandle(obj.figureHandle)
                    set(obj.figureHandle,...
                        'resizeFcn',              '',...
                        'WindowButtonMotionFcn',  '',...
                        'keyPressFcn',            '',...
                        'keyReleaseFcn',          '',...
                        'WindowButtonDownFcn',    '',...
                        'WindowButtonUpFcn',      '');
                end
            end
                         
        end
        
        %{
        -------------------------------------------------------------------
        Update the figure title and/or footer
        -------------------------------------------------------------------
        %}
        function update(obj)
           
            if ~isempty(obj.figureTitle)
                obj.figureTitle.update();
            end
            
            if ~isempty(obj.footer)
                obj.footer.update();
            end
            
        end
        
        function extent = getInnerExtent(obj,units)
        % Syntax:
        %
        % extent = getInnerExtent(obj,units)
        %
        % Description:
        %
        % Get inner extent of all children in a nb_figure object.
        % 
        % Written by Kenneth Sæterhagen Paulsen

        % Copyright (c) 2021, Kenneth Sæterhagen Paulsen    
            
            if nargin < 2
                units = get(obj.figureHandle,'units');
            end
        
            extent = nan(1,4);
        
            % Get left most
            place = 10000;
            axs   = obj.children;
            for ii = 1:size(axs,2)
                p = getLeftMost(axs(ii));
                if p < place
                    place = p;
                end
            end
            extent(1) = place;
            
            % Get right most
            place = -10000;
            axs   = obj.children;
            for ii = 1:size(axs,2)
                p = getRightMost(axs(ii));
                if p > place
                    place = p;
                end
            end
            extent(3) = place - extent(1);
            
            % Get bottom
            if isempty(obj.footer)
                yLow = 10000;
                axs  = obj.children;
                for ii = 1:size(axs,2)
                    y = getYLow(axs(ii));
                    if y < yLow
                        yLow = y;
                    end
                end
                extent(2) = yLow;
            else
                extent(2) = obj.footer.extent(2);
            end
            
            % Get top
            if isempty(obj.figureTitle)
                place = -10000;
                axs   = obj.children;
                for ii = 1:size(axs,2)
                    p = getYHigh(axs(ii));
                    if p > place
                        place = p;
                    end
                end
                extent(4) = place - extent(2);
            else
                extFig    = obj.figureTitle.extent;
                extent(4) = extFig(2) + extFig(4) - extent(2);
            end
            
            % Map into figure position
            if ~strcmpi(units,'normalized')
                pos       = nb_getInUnits(obj.figureHandle,'position',units);
                extent(1) = pos(1) + extent(1)*pos(3);
                extent(3) = extent(3)*pos(3);
                extent(2) = pos(2) + extent(2)*pos(4);
                extent(4) = extent(4)*pos(4);
            end
                
        end
        
    end
    
    methods(Access=public,Hidden=true)
        
        %{
        -------------------------------------------------------------------
        Add axes object to the 'children' property
        -------------------------------------------------------------------
        %}
        function addAxes(obj,axesHandle)
            
            % Look for the children which match
            found = 0;
            for ii = 1:size(obj.children,2)
                
                found = isequal(obj.children(ii),axesHandle);
                if found
                    break;
                end
                
            end
            
            if ~found
            
                % Then add the nb_axes object
                if isa(axesHandle,'nb_axes')
                    obj.children = [obj.children, axesHandle];
                else
                    error([mfilename ':: Only possible to add objects of class nb_axes to a object of class nb_figure'])
                end

                % Update the figureTitle and the footer
                update(obj);
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove an nb_axes object from the nb_figure object
        -------------------------------------------------------------------
        %}
        function removeAxes(obj,axesHandle)
            
            found = 0;
            
            % Look for the children which match
            for ii = 1:size(obj.children,2)
                
                found = isequal(obj.children(ii),axesHandle);
                if found
                    break;
                end
                
            end
            
            if found
                
                % Remove the found object
                obj.children = [obj.children(1:ii - 1), obj.children(ii + 1:end)];
                
            else
               error([mfilename ':: Did not found the given nb_axes object in the given nb_figure object.']) 
            end
            
            % Update the figureTitle and the footer
            update(obj);
            
        end
        
        %{
        -------------------------------------------------------------------
        Add figure title
        -------------------------------------------------------------------
        %}
        function addFigureTitle(obj,child)
            
            if ~isempty(obj.figureTitle) && ~isequal(obj.figureTitle,child)
                error([mfilename ':: It is not possible to add more than one figure title.'])
            end
            
            obj.figureTitle = child;
            
            obj.update();   
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove figure title
        -------------------------------------------------------------------
        %}
        function removeFigureTitle(obj,child)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if strcmpi(child.deleteOption,'all')
                if ~isempty(child.children)
                    for ii = 1:length(child.children)
                        delete(child.children(ii));
                    end
                    child.children = [];
                end
            end
            
            % Remove it from the figure object
            %--------------------------------------------------------------
            obj.figureTitle = [];
             
        end
        
        %{
        -------------------------------------------------------------------
        Add footer
        -------------------------------------------------------------------
        %}
        function addFooter(obj,child)
            
            if ~isempty(obj.footer) && ~isequal(obj.footer,child)
                error([mfilename ':: It is not possible to add more than one footer.'])
            end
            
            obj.footer = child;
            
            obj.update();   
            
        end
        
        %{
        -------------------------------------------------------------------
        Remove footer
        -------------------------------------------------------------------
        %}
        function removeFooter(obj,child)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if strcmpi(child.deleteOption,'all')
                if ~isempty(child.children)
                    for ii = 1:length(child.children)
                        delete(child.children(ii));
                    end
                    child.children = [];
                end
            end
            
            % Remove it from the figure object
            %--------------------------------------------------------------
            obj.footer = [];
             
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected,Hidden=true)
          
        function mouseMoveCallback(obj,~,~)
            
            if ~isvalid(obj)
                return
            end
            
            % Listening objects should never set this property to 'arrow'
            set(obj.figureHandle, 'pointer', 'arrow');            
            obj.notify('mouseMove');
            
        end
            
        function keyPressCallback(obj, ~,e) 
            eventData = nb_keyEvent(e.Character,e.Modifier,e.Key);
            obj.notify('keyPress',eventData);            
        end
        
        function keyReleaseCallback(obj, ~,e) 
            eventData = nb_keyEvent(e.Character,e.Modifier,e.Key);
            obj.notify('keyRelease',eventData);            
        end
        
        function mouseDownCallback(obj, ~, ~)
            obj.notify('mouseDown');          
        end
        
        function mouseUpCallback(obj, ~, ~)
            obj.notify('mouseUp');            
        end
        
        function resizeCallback(obj, ~,~) 
            obj.notify('resized');            
        end
        
    end
    
end
