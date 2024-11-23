classdef nb_xlabel < handle
% Syntax:
%     
% obj = nb_xlabel(parent,string,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for adding a x-label to a nb_axes handle    
%     
% Constructor:
%     
%     obj = nb_xlabel(parent,string,varargin)
%     
%     Input:
% 
%     - parent   : An object of class nb_axes
%
%     - string   : the label as string
% 
%     Optional input:
%
%     - varargin : 'propertyName',propertyValue,...
% 
%     Output:
% 
%     - obj      : A handle to the plot.
%     
%     Examples:
% 
%     First you need to make the nb_axes handle
%     ax = nb_axes();
% 
%     Then you can add the x-label 
%     nb_xlabel(ax,'A label');
% 
%     Other examples:
%
%     nb_xlabel(ax,'A label','propertyName',propertyValue,...);
%
%     titleHandle = nb_xlabel(ax,'A label','propertyName',...
%                             propertyValue,...);  
% 
%         same as
% 
%     nb_xlabel('A label','parent',ax,'propertyName',...
%               propertyValue,...); 
%
%     xlabelHandle = nb_xlabel('A label','parent',ax,...
%                              'propertyName',propertyValue,...);     
% 
%     Make new axes for the given x-label:
%
%     nb_xlabel('A label','propertyName',propertyValue,...);
%
%     xlabelHandle = nb_xlabel('A label','propertyName',...
%                              propertyValue,...);
%     
% See also
% nb_axes, xlabel
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties (SetAccess=protected)
        
        % The children will consist of one MATLAB text handle.
        children            = [];
        
    end
    
    properties
       
        % The figure title text alignment, default is 'center'. You 
        % also have 'left' and 'right'.
        alignment           = 'center';       
        
        % 'all' | {'only'}. If 'all' is given the object 
        % will be delete and all that is plotted by this 
        % object are removed from the figure it is plotted
        % on. If on the other hand 'only' is given, it 
        % will just delete the object.
        deleteOption        = 'only';           
                                                
        % The font name to use. As a string. 'arial' is 
        % default.                                        
        fontName            = 'arial';
        
        % The size of the font. As a scalar. Default is 14.
        fontSize            = 14;               
        
        % {'points'} | 'normalized' | 'inches' |  
        % 'centimeters' | 'pixels'
        % 
        % Font size units. MATLAB uses this property to 
        % determine the units used by the fontSize 
        % property.
        % 
        % normalized - Interpret FontSize as a fraction 
        % of the height of the parent axes. When you 
        % resize the axes, MATLAB modifies the screen 
        % fontSize accordingly.
        % 
        % pixels, inches, centimeters, and points: 
        % Absolute units. 1 point = 1/72 inch.
        fontUnits           = 'points';
        
        % The weight of the font, {'bold'} | 'normal' | 'light'
        fontWeight          = 'normal';         
        
        % position rectangle (read-only)
        % 
        % Position and size of text. A four-element vector that 
        % defines the size and position of the text string:
        % 
        % [left,bottom,width,height]
        % 
        % left and bottom are the x- and y-coordinates of the lower  
        % left corner of the text extent. The units are normalized.
        extent              = [];   
        
        % {'none'} | 'tex'  | 'latex'.
        interpreter         = 'none';
        
        % Indicate if the font when fontUnits is set to 'normalized'
        % should be normalized to the axes ('axes') or to the
        % figure ('figure'), i.e. the default axes position 
        % [0.1 0.1 0.8 0.8].
        normalized          = 'figure';
        
        % The parent, as a nb_axes handle (object).
        parent              = [];               
        
        % The placement of the title. {'center'} | 'left' | 'right' |
        % 'leftaxes'
        placement           = 'center';
        
        % A scalar which manage the space beetween the 
        % x-axis tick mark labels and the x-label. 
        offset              = 0;       
        
        % The text of the x-label. As a string or a char.
        string              = '';  
        
        % {'on'} | 'off'.
        visible             = 'on';                     
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function set.alignment(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The alignment property must be set'...
                                 ' to a character array.'])
            end
            obj.alignment = value;
        end
        
        function set.deleteOption(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The deleteOption property must be'...
                                 ' set to a one line character array.'])
            end
            obj.deleteOption = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontName property must be'...
                                 ' set to a character array.'])
            end
            obj.fontName = value;
        end
        
        function set.fontSize(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The fontSize property must be'...
                                 ' set to a double.'])
            end
            obj.fontSize = value;
        end
        
        function set.fontUnits(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontUnits property must be'...
                                 ' set to a one line character array.'])
            end
            obj.fontUnits = value;
        end
        
        function set.fontWeight(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontWeight property must be'...
                                 ' set to a one line character array.'])
            end
            obj.fontWeight = value;
        end
        
        function set.interpreter(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The interpretert property must be'...
                                 ' set to a one line character array.'])
            end
            obj.interpreter = value;
        end
        
        function set.normalized(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The normalized property must be'...
                                 ' set to a one line character array.'])
            end
            obj.normalized = value;
        end
        
        function set.placement(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The placement property must be'...
                                 ' set to a one line character array.'])
            end
            obj.placement = value;
        end
        
        function set.offset(obj,value)
            if ~nb_isScalarNumber(value)
                error([mfilename ':: The offset property must be'...
                                 ' set to a double.'])
            end
            obj.offset = value;
        end
        
        function set.extent(obj,value)
            if ~isvector(value) || ~(length(value) == 4)
                error([mfilename ':: The extent property must be'...
                                 ' set to a one line character array.'])
            end
            obj.extent = value;
        end
        
        function set.string(obj,value)
            if ~ischar(value) && ~isempty(value) && ~iscellstr(value)
                error([mfilename ':: The string property must be set to '...
                                 'a one line character array or a cellstr.'])
            end
            obj.string = value;
        end
        
        function obj = nb_xlabel(parent,string,varargin)
            
            if nargin > 0
            
                if nargin < 2
                    string = ''; % Empty text
                end

                if isa(parent,'nb_axes')
                    obj.parent = parent;
                    obj.string   = string;
                else
                    obj.parent = nb_axes();
                    obj.string = parent;
                    if nargin >= 2
                        varargin = [{string} varargin];
                    end
                end

                if size(varargin,2) > 0
                    obj.set(varargin{:});
                else
                    % Add the x-label to a default parent, where it is 
                    % plotted
                    obj.parent.addXLabel(obj);
                end
                
            end
            
        end
        
        varargout = set(varargin)
        
        varargout = get(varargin)
        
        %{
        -------------------------------------------------------------------
        Delete the object
        -------------------------------------------------------------------
        %}
        function delete(obj)
            
            % Remove it form its parent
            if isa(obj.parent,'nb_axes')
                if isvalid(obj.parent)
                    obj.parent.removeXLabel(obj);
                end
            end

            if strcmpi(obj.deleteOption,'all')
                
                % Delete all the children of the object 
                if ishandle(obj.children)
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
            
            obj.visible = get(obj.parent,'visible');
            
        end
        
        %{
        -------------------------------------------------------------------
        Update the handle given changes
        -------------------------------------------------------------------
        %}
        function update(obj)
            
            plotXLabel(obj)
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        function plotXLabelFast(obj)
            
            if strcmpi(obj.fontUnits,'normalized')
                pos = get(obj.parent.plotAxesHandle,'position');
                if ~strcmpi(obj.normalized,'axes')
                    fontS = obj.fontSize*0.8/pos(4);
                else
                    fontS = obj.fontSize;
                end
                fontU = obj.fontUnits;
            else
                fontU = obj.fontUnits;
                fontS = obj.fontSize;
            end
            
            obj.children = xlabel(obj.parent.plotAxesHandle,obj.string,...
                     'horizontalAlignment'  ,'center',...
                     'verticalAlignment'    ,'top',...
                     'fontName'             ,obj.fontName,...
                     'fontWeight'           ,obj.fontWeight,...
                     'fontUnits'            ,fontU,...
                     'fontSize'             ,fontS,...
                     'interpreter'          ,obj.interpreter,...
                     'visible'              ,obj.visible);  
            
        end
        
        %{
        -------------------------------------------------------------------
        Plot the x-label
        -------------------------------------------------------------------
        %}
        function plotXLabel(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                for ii = 1:length(obj.children)
                    if ishandle(obj.children(ii))
                        delete(obj.children(ii));
                    end
                end
                obj.children = [];
            end
            
            if obj.parent.fast
                plotXLabelFast(obj);
                return
            end
            
            %--------------------------------------------------------------
            % Need to find out where to place the x-label
            %--------------------------------------------------------------
           
            % The y-axis location
            y  = obj.parent.getYLow(1) + obj.offset;

            % The x-axis location
            pos  = obj.parent.position;
            switch obj.placement
                case 'center'
                    x = pos(1) + pos(3)/2;
                case 'leftaxes'
                    p = get(obj.parent,'position');
                    x = p(1);
                case 'left'
                    x = getLeftMost(obj.parent);
                case 'right'
                    x = getRightMost(obj.parent);
                otherwise
                    error([mfilename ':: No placement type ' ...
                         obj.placement ' for the property ''placement''.'])
            end
            
            %--------------------------------------------------------------
            % If the font size is normalized we get the font size
            % transformed to another units
            %--------------------------------------------------------------
            if strcmpi(obj.fontUnits,'normalized')

                axh = obj.parent.plotAxesHandle;
                pos = get(axh,'position');
                if ~strcmpi(obj.normalized,'axes')
                    fontS = obj.fontSize*0.8/pos(4);
                else
                    fontS = obj.fontSize;
                end
                fontU = obj.fontUnits;

            else
                fontU = obj.fontUnits;
                fontS = obj.fontSize;
            end
            
            %--------------------------------------------------------------
            % Start the plotting
            %--------------------------------------------------------------
            obj.children = text(x,y,obj.string,...
                     'horizontalAlignment'  ,'center',...
                     'verticalAlignment'    ,'top',...
                     'fontName'             ,obj.fontName,...
                     'fontWeight'           ,obj.fontWeight,...
                     'fontUnits'            ,fontU,...
                     'fontSize'             ,fontS,...
                     'horizontalAlignment'  ,obj.alignment,...
                     'interpreter'          ,obj.interpreter,...
                     'parent'               ,obj.parent.axesLabelHandle,...
                     'visible'              ,obj.visible);

            % Get the extent of the yLabel
            drawnow; % Or else extent will not be calculated correctly
            obj.extent = get(obj.children,'extent'); % May turn it into dependent instead?
            
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
    
end
