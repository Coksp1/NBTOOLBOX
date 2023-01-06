classdef nb_footer < matlab.mixin.Copyable
% Syntax:
%     
% obj = nb_footer(string,varargin)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% This is a class for making footers on an nb_figure object. Placed
% below all elements of the figure  
%     
% Constructor:
%     
%     obj = nb_footer(string,varargin)
%     
%     %     Input:
% 
%     - string   : The text of the footer, as a string or a char. 
%                  If it is a char, each row will be added as
%                  a separate lines.
% 
%     - varargin : ...,'propertyName',propertyValue,...  
%     
%     Output
% 
%     - obj      : An object of class nb_footer
%     
%     Examples:
% 
%     nb_footer('A footer')
%     f = nb_footer('A footer')
%     f = nb_footer(char('A footer','New line'))
%     f = nb_footer('A footer','propertyName',...
%                    propertyValue)
%  
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Protected properties of the object
    %======================================================================
    properties(SetAccess=protected)
        
        % The children of the object. As MATLAB text object(s).
        children = [];         
                
    end
        
    %======================================================================
    % Properties of the class
    %======================================================================
    properties     
        
        % The footer alignment, default is 'left'. You also have 
        % 'center' and 'right'.
        alignment           = 'left';           
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption        = 'only';  
        
        % Font name used for the footer. 'arial' is default.
        fontName            = 'arial';  
        
        % Size of the text. Must be a scalar.
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
        
        % The footer font weigth, either 'bold', 'normal' or 
        % 'light'.
        fontWeight          = 'normal';    
        
        % Latex interpretation is default, set it to 'none' 
        % otherwise.
        interpreter         = 'tex';  
        
        % The parent of the plotting object. Must be a nb_figure object.
        parent              = [];
        
        % Where to place the footer in the x-axis direction, either
        % 'center', 'right', 'leftaxes' or the default value 
        % 'left'.
        placement           = 'left';  
        
        % A 1x2 double with the position of the figure title.
        position            = nan(1,2);     
        
        % The footer text, as a string or a char with the text. If 
        % it is a char, each row will be added as a separate lines.
        string              = '';        
        
        % Sets the visibility of the radar plot. {'on'} | 'off'.
        visible             = 'on';
        
        % Wrap text of footer, i.e. make automatic line breaks.
        wrap                = false;
        
    end
    
    %======================================================================
    % Dependent properties of the object
    %======================================================================
    properties (Dependent=true)
        
        % The extent of the figure title object. Specifies a rectangle  
        % that locates in the units of the first child of the parent 
        % object. The vector is of the form: [left bottom width  
        % height], where left and bottom define the distance from the 
        % lower-left corner of the container to the lower-left corner of  
        % the rectangle. width and height are the dimensions of the 
        % rectangle. Allways in normalized units.
        extent 
 
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function value = get.extent(obj)
            value = nb_getInUnits(obj.children,'extent','normalized');
        end
        
        function set.alignment(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'left','center',...
                                                        'right'},value))
                error([mfilename ':: The alignment property must be'...
                                 ' set to either ''left'',''center'', or'...
                                 ' ''right''.'])
            end
            obj.alignment = value;
        end
        
        function set.deleteOption(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'only','all'},...
                                                                    value))
                error([mfilename ':: The deleteOption property must be'...
                                 ' set to either ''only'' or ''all''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value) 
                error([mfilename ':: The fontName property must be'...
                                 ' given as a one line char.'])
            end
            obj.fontName = value;
        end
        
        function set.fontSize(obj,value)
            if ~isscalar(value)
                error([mfilename ':: The deleteOption property must be'...
                                 ' given as a scalar.'])
            end
            obj.fontSize = value;
        end
        
        function set.fontUnits(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'points',...
                                                        'normalized'...
                                'inches','centimeters','pixels'},value))
                error([mfilename ':: The fontUnits property must be'...
                            ' set to either ''points'', ''normalized'''...
                            ' ''inches'', ''centimeters'' or ''pixels''.'])
            end
            obj.fontUnits = value;
        end
        
        function set.fontWeight(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'light','bold',...
                                                        'normal'},value))
                error([mfilename ':: The fontWeight property must be'...
                                 ' set to either ''bold'' or ''normal'' or'...
                                 ' ''light''.'])
            end
            obj.fontWeight = value;
        end

        function set.interpreter(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'tex','none'},...
                                                                    value))
                error([mfilename ':: The interpreter property must be'...
                                 ' set to either ''tex'' (default) or ',...
                                 ' ''none''.'])
            end
            obj.interpreter = value;
        end
        
        function set.parent(obj,value)
            if ~isa(value,'nb_figure') && ~isempty(value)
                error([mfilename ':: The parent property must be ',...
                       'given as a nb_figure object.'])
            end
            obj.parent = value;
        end      
        
        function set.placement(obj,value)
            if ~nb_isOneLineChar(value) && ~any(strcmp({'center','right',...
                                                        'leftaxes','left'}...
                                                                   ,value))
                error([mfilename ':: The placement property must be'...
                                 ' set to either ''center'' or ''right'''...
                                 ' ''leftaxes'' or ''left''.'])
            end
            obj.placement = value;
        end
        
        function set.visible(obj,value)
            if ~any(strcmp({'on','off'},value))
                error([mfilename ':: The visibility property must be '...
                      ' set to either ''on'' (default) or ''off''.'])
            end
            obj.visible = value;
        end        
        
        function set.position(obj,value)
            if ~isvector(value) 
                error([mfilename ':: The position property must be a '...
                      '1x2 double with the position of the figure title.'])
            end
            obj.position = value;
        end 
        
        function set.string(obj,value)
            if ~ischar(value) && ~isempty(value)
                error([mfilename ':: The string property must be given'...
                      ' as a char.'])
            end
            obj.string = value;
        end   
        
        function set.wrap(obj,value)
            if ~nb_isScalarLogical(value)
                error([mfilename ':: The wrap property must be given'...
                      ' as a scalar logical.'])
            end
            obj.wrap = value;
        end 
        
        function obj = nb_footer(string,varargin)
            
            if nargin > 0
                
                obj.string = string;
                obj.set(varargin{:});
                
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
            if isa(obj.parent,'nb_figure')
                if isvalid(obj.parent)
                    obj.parent.removeFooter(obj);
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
        Update the footer
        -------------------------------------------------------------------
        %}
        function update(obj)
            
            plotFooter(obj);
            
        end
        
        function s = struct(obj)
            
            s = struct(...
                'alignment',    obj.alignment,...
                'deleteOption', obj.deleteOption,...
                'fontName',     obj.fontName,...
                'fontSize',     obj.fontSize,...
                'fontUnits',    obj.fontUnits,...
                'fontWeight',   obj.fontWeight,...
                'interpreter',  obj.interpreter,...
                'placement',    obj.placement,...
                'position',     obj.position,...
                'string',       obj.string,...
                'visible',      obj.visible,...
                'wrap',         obj.wrap);
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Plot the footer in the given figure
        -------------------------------------------------------------------
        %}
        function plotFooter(obj)
            
            if isempty(obj.parent.children)
                warning([mfilename ':: The given figure has no axes! Not possible to add a footer.'])
                return
            end
            
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
            
            %--------------------------------------------------------------
            % Find the placement of the footer
            %--------------------------------------------------------------
            if isnan(obj.position(1))
            
                switch obj.placement

                    case 'center'

                        place = 0.5;

                    case 'leftaxes'
                        
                        place = 10000;
                        axs   = obj.parent.children;
                        for ii = 1:size(axs,2)
                            p = get(axs(ii),'position');
                            if p(1) < place
                                place = p(1);
                            end
                        end
                            
                    case 'left'

                        place = 10000;
                        axs   = obj.parent.children;
                        for ii = 1:size(axs,2)
                            p = getLeftMost(axs(ii));
                            if p < place
                                place = p;
                            end
                        end
                        
                    case 'right'

                        place = -10000;
                        axs   = obj.parent.children;
                        for ii = 1:size(axs,2)
                            p = getRightMost(axs(ii));
                            if p > place
                                place = p;
                            end
                        end

                    otherwise

                        error([mfilename ':: No placement type ' obj.placement ' for the property ''placement''.'])
                end
                
            else
                
                place = obj.position(1);
                
            end

            if isnan(obj.position(2))
                yLow = 10000;
                axs  = obj.parent.children;
                for ii = 1:size(axs,2)
                    y = getYLow(axs(ii));
                    if y < yLow
                        yLow = y;
                    end
                end
            else
                yLow = obj.position(2);
            end
            
            %--------------------------------------------------------------
            % Plot it
            %--------------------------------------------------------------
            if ischar(obj.string)

                axh = obj.parent.children(1).axesLabelHandle;
                if ~isempty(obj.string)

                    if obj.wrap
                        str = cellstr(obj.string);
                        if length(str) > 1
                           str = strcat(str,{' '});
                           str = [str{:}];
                           str = strsplit(str,'//'); % Force line break!
                        end
                    else
                        str = obj.string;
                    end
                    
                    t = text(place, yLow,           str,...
                            'fontUnits',            obj.fontUnits,...
                            'fontSize',             obj.fontSize,...
                            'FontName',             obj.fontName,...
                            'FontWeight',           obj.fontWeight,...
                            'Interpreter',          'tex',...
                            'parent',               axh,...
                            'HorizontalAlignment',  obj.alignment,...
                            'VerticalAlignment',    'top');
                        
                    obj.children = t;

                    if obj.wrap
                        nb_wrapFigureText(obj,t,place);
                    end
                    
                end
                
            else
                error([mfilename ':: The ''string'' property must be a string or a char. Is: ' class(obj.string)])
            end
            
        end
        
        function copyObj = copyElement(obj)
        % Overide the copyElement method of the 
        % matlab.mixin.Copyable class to remove some MATLAB 
        % handles
        
            % Copy main object
            copyObj          = copyElement@matlab.mixin.Copyable(obj);
            copyObj.children = [];
            copyObj.parent   = [];
            
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        function obj = unstruct(s)
            
            obj    = nb_footer();
            fields = fieldnames(s);
            for ii = 1:length(fields)
                obj.(fields{ii}) = s.(fields{ii}); 
            end
            
        end
        
    end
    
end
