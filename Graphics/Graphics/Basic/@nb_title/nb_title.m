classdef nb_title < handle
% Syntax:
%     
% obj = nb_title(parent,string,varargin)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% This is a class for adding a title to a nb_axes handle    
%        
% Constructor:
%     
%     obj = nb_title(parent,string,varargin)
% 
%     Input:
% 
%     - parent   : An object of class nb_axes
% 
%     - string   : The title as a string
% 
%     Optional input:
% 
%     - varargin : ...,'propertyName',propertyValue,...
% 
%     Output:
% 
%     - obj      : An object of class nb_title
%     
%     Examples:
% 
%     First you need to make the nb_axes handle
%     ax = nb_axes();
% 
%     Then you can add the title 
%     nb_title(ax,'A title');
% 
%     nb_title(ax,'A title','propertyName',propertyValue,...); 
%
%     titleHandle = nb_title(ax,'A title','propertyName',...
%                            propertyValue,...);  
% 
%         same as
% 
%     nb_title('A title','parent',ax,'propertyName',...
%              propertyValue,...); 
%
%     titleHandle = nb_title('A title','parent',ax,...
%                            'propertyName',propertyValue,...);     
% 
%     Make new axes for the given title:
%
%     nb_title('A title','propertyName',propertyValue,...); 
%
%     titleHandle = nb_title('A title','propertyName',...
%                            propertyValue,...);  
%  
% See also:
% title, nb_axes
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties (SetAccess = protected)
        
        % The children will consist of one MATLAB title handle.
        children = [];     
    
    end
        
    properties
       
        % The figure title text alignment, default is 'center'. You 
        % also have 'left' and 'right'.
        alignment           = 'center';           
        
        % 'all' | {'only'}. If 'all' is given the object 
        %  will be delete and all that is plotted by this 
        %  object are removed from the figure it is plotted
        %  on. If on the other hand 'only' is given, it 
        %  will just delete the object.
        deleteOption        = 'only';
        
        % The font name to use. As a string. Default is
        % 'arial'
        fontName            = 'arial'; 
        
        % The size of the font. As a scalar.
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
        
        % The weight of the font, {'bold'} | 'normal' | 'light'.
        fontWeight          = 'bold';   
        
        % {'none'} | 'tex'  | 'latex'
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
        
        % The text of the title. As a char. Multi-lined char gives
        % a multi-lined title.
        string              = '';
        
        % Sets the visibility of the radar plot. {'on'} | 'off'.
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
        
        function set.string(obj,value)
            if ~ischar(value) && ~isempty(value) && ~iscellstr(value)
                error([mfilename ':: The string property must be'...
                                 ' set to a one line (or empty) '...
                                 'character array or a cellstr.'])
            end
            obj.string = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The visible property must be'...
                                 ' set to either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
                
        function obj = nb_title(parent,string,varargin)
            
            if nargin > 0
                
                if nargin < 2
                    string = ''; % Empty text
                end

                if isa(parent,'nb_axes')
                    obj.parent = parent;
                    obj.string = string;
                else
                    obj.string = parent;

                    if nargin >= 2
                        varargin = [{string} varargin];
                    end

                end

                if size(varargin,2) > 0
                    obj.set(varargin{:});
                else

                    % If initialize the parent axes
                    if isempty(obj.parent)
                        obj.parent = nb_axes();
                    end

                    % Add the nb_title handle to its parent
                    obj.parent.addTitle(obj);

                end
                
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

            % Remove it from its parent
            if isa(obj.parent,'nb_axes')
                if isvalid(obj.parent)
                    obj.parent.removeTitle(obj);
                    if strcmpi(obj.deleteOption,'all')
                        t = get(obj.parent.plotAxesHandle,'title');
                        set(t,'string','','fontName','helvetica','fontSize',10,'fontWeight','normal'); 
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
        Update the title 
        -------------------------------------------------------------------
        %}
        function update(obj)
           
            plotTitle(obj);
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Plot the title (or change the )
        -------------------------------------------------------------------
        %}
        function plotTitle(obj)
            
            % Get the MATLAB axes handle of the nb_axes handle which the
            % title should be placed on
            if obj.parent.fast
                ax = obj.parent.plotAxesHandle;
            else
                ax = obj.parent.axesLabelHandle;
            end
            
            % Need to construct a MATLAB handle if not already done
            if isempty(obj.children) || isempty(obj.parent.title) || ~ishandle(obj.children)
                % Initialize the title
                obj.children = title(ax,obj.string);
            end
            
            % If the font size is normalized we get the font size
            % transformed to another units
            %------------------------------------------------------
            if strcmpi(obj.fontUnits,'normalized')

                pos = get(ax,'position');
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
            
            % Then set the properties of the title
            set(obj.children,'String',              obj.string,...
                             'fontName',            obj.fontName,...
                             'fontWeight',          obj.fontWeight,...
                             'fontUnits',           fontU,...
                             'fontSize',            fontS,...
                             'horizontalAlignment', obj.alignment,...
                             'interpreter',         obj.interpreter,...
                             'visible',             obj.visible);
               
            %--------------------------------------------------------------
            % Find the placement of the title
            %--------------------------------------------------------------             
            if ~obj.parent.fast
            
                pos = get(obj.children,'position');
                switch obj.placement
                    case 'center'
                        p      = get(obj.parent,'position');
                        pos(1) = p(1) + p(3)/2;
                    case 'leftaxes'
                        p      = get(obj.parent,'position');
                        pos(1) = p(1);
                    case 'left'
                        pos(1) = getLeftMost(obj.parent);
                    case 'right'
                        pos(1) = getRightMost(obj.parent);
                    otherwise
                        error([mfilename ':: No placement type ' obj.placement ' for the property ''placement''.'])
                end
                set(obj.children,'position',pos);
                
            end
                                     
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
    
end
