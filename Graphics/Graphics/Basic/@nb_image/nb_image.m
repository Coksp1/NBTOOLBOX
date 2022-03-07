classdef nb_image < nb_plotHandle
% Syntax:
%     
% obj = nb_image(cData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for plotting images. 
% 
% The handle have set and get methods as all MATLAB graph handles.     
%     
% Constructor:
%     
%     obj = nb_image(cData,'propertyName',propertyValue,...)
%     
%     Input:
%     
%     - cData    : The data of the image. Must be a double of size M x N
%                  (mapped into the colormap) or M x N x 3 (RGB).
%
%                  In the case that the parent is of class nb_axes the
%                  current colormap can be set by nb_colormap, otherwise
%                  use colormap.
%         
%     - varargin : ...,'propertyName',propertyValue,...      
%     
%     Output:
%     
%     - obj      : An object of class nb_image 
%
%     Examples:
%
%     nb_image(rand(5,5));
%     obj = nb_image(rand(5,5,3)*255);
%     
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties (SetAccess=protected)
        
        % All the handles of the area plot, as nb_patch objects
        children            = []; 
        
    end
    
    properties
       
        % When true, white is added to the colorMap property before
        % interpreting the cData. Default is true.
        appendWhite         = true;
        
        % The data of the image. Must be a double of size M x N
        % (mapped into the colormap) or M x N x 3 (RGB).
        %
        % In the case that the parent is of class nb_axes the current 
        % colormap can be set by nb_colormap
        cData               = []; 
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption        = 'only';    
          
        % {'off'} : Not included in the legend. 'on' : 
        % included in the legend
        legendInfo          = 'off';       
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes (Which is the default).
        side                = 'left';   
              
        % Sets the visibility of the plotted lines. {'on'} | 'off' 
        visible             = 'on';        
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        type = 'patch';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        %{
        -------------------------------------------------------------------
        Constructor of the nb_area class
        -------------------------------------------------------------------
        %}
        function obj = nb_image(cData,varargin)
            
            if nargin < 1
                cData = rand(5,5);
            end
            
            obj.cData = cData;
            if nargin > 2
                obj.set(varargin);
            else
                % Then just plot
                plot(obj);
            end
            
        end
        
        function set.appendWhite(obj,value)
            if ~nb_isScalarLogical(value)
                error([mfilename ':: The appendWhite property must be a scalar logical (true/false).'])
            end
            obj.appendWhite = value;
        end
        
        function set.cData(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The cData property must be'...
                                 ' of size M x N (x 3).'])
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
        
        function set.legendInfo(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The legendInfo property must be'...
                                 ' set to a one line character array.'])
            end
            obj.legendInfo = value;
        end
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename ':: The side property must be'...
                                 ' set to either ''left'' or ''right''.'])
            end
            obj.side = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The visible property must be'...
                                 ' set to either ''on'' or ''off''.'])
            end
            obj.visible = value;
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
                    obj.parent.removeChild(obj);
                end
            end

            % Delete all the children of the object 
            for ii = 1:size(obj.children,2)
               
                if isvalid(obj.children(ii))
                    
                    % Set the delete option for the children
                    obj.children(ii).deleteOption = obj.deleteOption;
                    
                    % Then delete
                    delete(obj.children(ii))
                    
                end
                
            end
             
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
            for ii = 1:size(obj.children,2)
                set(obj.children(ii),'visible',obj.visible);
            end
            
        end
        
    end
    
    methods(Hidden=true)
        
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        The method which does the plotting
        -------------------------------------------------------------------
        %}
        function plot(obj)
            
            if isempty(obj.parent)
                obj.parent = nb_axes();
            end
            
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
            % Start plotting
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                % Update the axes given the plotted data, plotting will
                % take place in the addShading method of the nb_axes class
                obj.parent.addChild(obj);
            else
                if size(obj.cData,3) == 1
                    im = imagesc(obj.cData,'parent',obj.parent);
                else
                    im = image(obj.cData,'parent',obj.parent);
                end
                obj.children = im;
            end
            
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
         
    end
    
end
