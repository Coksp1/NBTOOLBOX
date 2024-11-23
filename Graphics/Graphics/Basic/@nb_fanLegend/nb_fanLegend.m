classdef nb_fanLegend < handle
% Syntax:
%     
% obj = nb_fanLegend(parent,string,varargin)
%     
% Description:
%     
% This is a class for creating MPR looking legends for the fan 
% charts 
%     
% Constructor:
%     
%     obj = nb_fanLegend(parent,string,varargin)
%     
%     Input:
% 
%     - parent   : An object of class nb_axes. One of its 
%                  children must be of class nb_fanChart.  
%
%     - string   : Sets the text over the colored boxes of the  
%                  MPR looking fan legend, you must give them as   
%                  a cellstr. Must match the number of percentiles 
%                  of the graph created by the nb_fanChart object.
%                  E.g. {'30%','50%','70%','90%'}. If empty the 
%                  percentiles of the underling nb_fanChart 
%                  object will be used.
%
%     - varargin : Property name, property value combinations.
%     
%     Output
% 
%     - obj      : An object of class nb_fanLegend
%     
%     Examples:
% 
%     fan = nb_fanChart([ones(20,100)*0.5;rand(10,100)],...
%                       'cData','grey');
%     obj = nb_fanLegend(fan.parent,{})  
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties(SetAccess=protected)

        % The children of the fan legend. As MATLAB handles.
        children            = [];
        
        % Colors of the fan layers. As a M X 3 double with
        % the RGB colors. Should not be set.
        colors              = []; 
        
    end

    properties
        
        % 'all' | {'only'}. If 'all' is given the object 
        % will be delete and all that is plotted by this 
        % object are removed from the figure it is plotted
        % on. If on the other hand 'only' is given, it 
        % will just delete the object.
        deleteOption        = 'only';           
            
        % The extent of the fan legend. A 1x2 double with the
        % lower left point.
        extent              = [];
        
        % The font name to use. As a string. 'arial' is 
        % default.                                        
        fontName            = 'arial';
        
        % The size of the font. As a scalar. Default is 14.
        fontSize            = 12;               
        
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
        fontWeight          = 'normal';         
        
        % {'none'} | 'tex'  | 'latex'
        interpreter         = 'none';           
        
        % Sets the location of the fan legend. Must be a
        % string or a 1 x 2 double. 
        % 
        % Different location supported:
        % 
        % - 'Best'      : (same as 'North'.)
        % - 'NorthWest'
        % - 'North'
        % - 'NorthEast'
        % - 'SouthEast'
        % - 'South'
        % - 'SouthWest'
        % - 'outside'   : Places the legend outside the 
        %                axes, one the right side. (If 
        %                you create subplots, this is 
        %                the only option which will 
        %                look good.)
        % 
        % You can also give a 1 x 2 double vector with  
        % the location of where to place the legend.  
        % First column is the x-axis location and the 
        % second column is the y-axis location. Both 
        % must be between 0 and 1.  
        location            = 'best';  
        
        % The parent, as a nb_axes handle (object)
        parent              = [];               
        
        % Text above the squared colorboxes of the legend.
        % As a cellstr. Must match the number of 
        % percentiles of the underlying nb_fanChart 
        % object. E.g. {'30%','50%','70%','90%'}. If empty  
        % the percentiles of the underling nb_fanChart 
        % object will be used.
        string              = {}; 
        
        % {'on'} | 'off'.
        visible             = 'on';            
        
    end
    
    methods
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.extent(obj,value)
            if ~isvector(value) && ~isempty(value) 
                error([mfilename ':: The extent property must be'...
                                 ' set to a one line character array.'])
            end
            obj.extent = value;
        end
        
        function set.fontName(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontName property must be a'...
                      ' one line char with the font name.'])
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
            if ~any(strcmp({'points','normalized','inches','centimeters',...
                            'pixels'},value))
                error([mfilename '::  The fontUnits property must'...
                    ' either ''points'', ''normalized'',''inches''',...
                    '''centimeters'', or ''pixels'''])
            end
            obj.fontUnits = value;
        end           
        
        function set.fontWeight(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fontWeight property must be a'...
                      ' one line char with the font size. ''normal''',...
                      ' is default.'])
            end
            obj.fontWeight = value;
        end
        
        function set.interpreter(obj,value)
            if ~any(strcmp({'latex','tex','none'},value))
                error([mfilename ':: The interpreter property must be ',...
                       'set to either ''latex'',''tex'' or ''none''.'])
            end
            obj.interpreter = value;
        end         
        
        function set.location(obj,value)
            if ~nb_isOneLineChar(value) && ~isa(value,'double')
                error([mfilename '::  The location property must be '...
                      'given as a one line character array or as a '...
                      '1x2 double'])
            end
            obj.location = value;
        end
        
        function set.parent(obj,value)
            if ~nb_isOneLineChar(value) && isa(value,'double')
                error([mfilename '::  The parent property must be '...
                      'given as an nb_axes object.'])
            end
            obj.parent = value;
        end        
                

        function set.string(obj,value)
            if ~isa(value,'cell') && ~isempty(value)
                error([mfilename ':: The string property must be'...
                                 ' given as a cellstring.'])
            end
            obj.string = value;
        end

        
        function set.visible(obj,value)
            if ~any(strcmp({'off','on'},value))
                error([mfilename '::  The visible property must be set to'...
                      'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end       
        
        function obj = nb_fanLegend(parent,string,varargin)
            
            if isa(parent,'nb_axes')
                obj.parent = parent;
            else
                error([mfilename ':: The input axesofplot must an object of class nb_axes. Is ' class(parent)])
            end

            % Find out if any of the children of the axesofplot input is a
            % nb_fanChart handle
            %--------------------------------------------------------------
            ret = 0;
            for ii = 1:length(parent.children)
                
                ret = isa(parent.children{ii},'nb_fanChart');
                if ret
                    break;
                end
                
            end
            
            % If found get the color data
            %--------------------------------------------------------------
            if ret == 1
                obj.colors = parent.children{ii}.cData;
            else
                error([mfilename ':: Parent axes doesn''t contain any nb_fanChart handle. So I cannot produce a fan legend.'])
            end
            
            % Assign and test some inputs
            %--------------------------------------------------------------
            obj.string = string;
            if ~isempty(string)
                if size(obj.colors,1) ~= size(obj.string,2)
                   error([mfilename ':: The property ''colors'' must have as many rows (' int2str(size(obj.colors,1)) ') as there are '...
                                    'columns of ''string'' property (' int2str(size(obj.string,2)) ').']) 
                end
            end
            
            % Set some properties and plot
            %------------------------------------------------------
            obj.set(varargin);
                        
        end
        
        varargout = set(varargin)
        varargout = get(varargin)
        
        function delete(obj)
        % Deletes the object
       
            if strcmpi(obj.deleteOption,'all')
                
                % Delete all the children of the object 
                for ii = 1:size(obj.children,2)
                    
                    if ishandle(obj.children(ii))

                        delete(obj.children(ii))

                    end
                    
                end
                
            end
             
        end
        
    end
    
    methods(Access=protected)
        
        function createLegend(obj)
            
            % Delete all children
            for ii = 1:size(obj.children,2)
                if ishandle(obj.children(ii))
                    delete(obj.children(ii));
                end
            end
            
            % Find out the text of the legend
            fan    = [];
            childs = obj.parent.children;
            for ii = 1:length(childs)

                ret = isa(childs{ii},'nb_fanChart');
                if ret
                    fan = childs{ii};
                    break;
                end

            end
            
            percentiles = fan.percentiles;
            if isempty(obj.string)
                
                % Create the default text of the legend
                percentiles = percentiles*100;
                str         = num2str(percentiles');
                obj.string  = cellstr(strcat(str,'%'));
                
            else
               
                if ischar(obj.string)
                    obj.string = cellstr(obj.string);
                elseif ~iscellstr(obj.string)
                    error([mfilename ':: The proeprty string must be set to a cellstr.'])
                end
                
                if length(obj.string) ~= length(percentiles)
                    error([mfilename ':: You have not provided the correct number of text strings to the property string. Is '...
                                      int2str(length(obj.string)) ', but need to be ' int2str(length(percentiles))])
                end
                
            end
            
            % Number of legend colors
            num = size(obj.colors,1);
            
            % The axes to plot the legend on
            %------------------------------------------------------
            axh  = obj.parent.axesLabelHandle;
            pos  = get(axh,'position');
            
            % Find the location of the fan legend
            %------------------------------------------------------
            if ischar(obj.location)
            
                if strcmpi(obj.location,'outside')

                    % Get the location of the fan legend
                    %----------------------------------------------
                    diff = 1/30;
                    
                    % Find the x-axis location of the color boxes and text
                    xPos      = obj.parent.getLeftMost() - 0.006;
                    xLocation = [xPos,   xPos - diff, xPos - diff, xPos];
                    
                    % Find the y-axis location of the color boxes and text
                    if rem(num, 2) == 0
                        corr1 = num/2;
                        corr2 = num/2 - 0.5;
                    else
                        corr1 = num/2;
                        corr2 = floor(num/2);
                    end

                    yspace    = diff + 0.015;
                    first     = 0.55 - diff*corr1 - yspace*corr2; %axesPositions(2) + axesPositions(4)/2
                    yLocation = nan(num,4);
                    for ii = 1:num
                        yLocation(ii,:) = [first + (diff+yspace)*(ii-1),...
                                           first + (diff+yspace)*(ii-1),...
                                           first + (diff+yspace)*(ii-1) - diff,...
                                           first + (diff+yspace)*(ii-1) - diff];  
                    end

                else % Put legend inside the axes

                    diffY            = 1/40;
                    diffX            = 1/50;
                    space            = 0.015;
                    xSpaceAdded      = 0.05;
                    ySpaceAdded      = 0.075;

                    switch lower(obj.location)

                        case 'best'

                            warning('nb_fanLegend:NoLocationBest','No location ''Best'' for the class nb_legend. Sets it to ''North''.') 

                            if rem(num, 2) == 0

                                corr1 = num/2;
                                corr2 = num/2 - 0.5;
                            else

                                corr1 = num/2;
                                corr2 = floor(num/2);

                            end

                            first  = pos(1) + pos(3)/2 - diffX*corr1 - space*corr2;
                            yspace = pos(2) + pos(4) - ySpaceAdded;

                        case 'north'

                            if rem(num, 2) == 0

                                corr1 = num/2;
                                corr2 = num/2 - 0.5;
                            else

                                corr1 = num/2;
                                corr2 = floor(num/2);

                            end

                            first  = pos(1) + pos(3)/2 - diffX*corr1 - space*corr2;
                            yspace = pos(2) + pos(4) - ySpaceAdded;

                        case 'south'

                            if rem(num, 2) == 0

                                corr1 = num/2;
                                corr2 = num/2 - 0.5;
                            else

                                corr1 = num/2;
                                corr2 = floor(num/2);

                            end

                            first  = pos(1) + pos(3)/2 - diffX*corr1 - space*corr2;
                            yspace = pos(2) + ySpaceAdded;

                        case 'east'

                            first  = pos(1) + pos(3) - xSpaceAdded - num*(diffX) - (num-1)*space;
                            yspace = pos(2) + pos(4)/2;

                        case 'west'

                            first  = pos(1) + xSpaceAdded;
                            yspace = pos(2) + pos(4)/2;

                        case 'northwest'

                            first  = pos(1) + xSpaceAdded;
                            yspace = pos(2) + pos(4) - ySpaceAdded;

                        case 'northeast'

                            first  = pos(1) + pos(3) - xSpaceAdded - num*(diffX) - (num-1)*space;
                            yspace = pos(2) + pos(4) - ySpaceAdded;

                        case 'southwest'

                            first  = pos(1) + xSpaceAdded;
                            yspace = pos(2) + ySpaceAdded;

                        case 'southeast'

                            first  = pos(1) + pos(3) - xSpaceAdded - num*(diffX) - (num-1)*space;
                            yspace = pos(2) + ySpaceAdded;

                        otherwise

                            error([mfilename ':: No legend placement ' obj.location])

                    end
                    
                    % Assign the extent
                    obj.extent = [first,yspace];

                    % Find the x-axis location of the color boxes and text
                    xLocation = nan(num,4);
                    for ii = 1:num
                        xLocation(ii,:) = [first + (diffX+space)*(ii-1),...
                                           first + (diffX+space)*(ii-1),...
                                           first + (diffX+space)*(ii-1) + diffX,...
                                           first + (diffX+space)*(ii-1) + diffX];  
                    end

                    % Find the y-axis location of the color boxes and text
                    yLocation = [yspace,   yspace - diffY, yspace - diffY, yspace];
                    
                end
                
            elseif isnumeric(obj.location)
                
                if ~(size(obj.location,2) == 2 && size(obj.location,1) == 1)
                    error([mfilename ':: The property ''location'' must have the size (1x2), when given as double array. '...
                                     'With the location of the legend in the plot (x-axis x y-axis). Given that the whole figure spans 0 to 1 in both directions.'])
                end
                
                first  = pos(1) + obj.location(1)*pos(3);
                yspace = pos(2) + obj.location(2)*pos(4);
                diffX  = 1/50;
                diffY  = 1/40;
                space  = 0.015;
                
                % Assign the extent
                obj.extent = [first,yspace];
                
                % Find the x-axis location of the color boxes and text
                xLocation = nan(num,4);
                for ii = 1:num
                    xLocation(ii,:) = [first + (diffX+space)*(ii-1),...
                                       first + (diffX+space)*(ii-1),...
                                       first + (diffX+space)*(ii-1) + diffX,...
                                       first + (diffX+space)*(ii-1) + diffX];  
                end

                % Find the y-axis location of the color boxes and text
                yLocation = [yspace,  yspace - diffY, yspace - diffY, yspace];

            else
                error([mfilename ':: The property ''location'' must either be a string or a (1x2) double with the location of the legend in the plot.'])
            end
            
            % Plot the legend
            %_-----------------------------------------------------
            p = nan(1,size(obj.colors,1));
            t = nan(1,size(obj.colors,1));
            if strcmpi(obj.location,'outside')
                
                for ii = 1:size(obj.colors,1)

                    % Adds a square with the color of this fan color
                    p(ii) = patch(xLocation,yLocation(ii,:),obj.colors(ii,:),...
                              'clipping',       'off',...
                              'edgecolor',      'none',...
                              'parent',         axh,...
                              'visible',        obj.visible);

                    % Adds a test to the colored square
                    t(ii) = text(xLocation(1,1) + (xLocation(1,3) - xLocation(1,1))/2, yLocation(ii,1) + 1/50,...
                                 obj.string{ii},...
                                 'fontName',            obj.fontName,...
                                 'fontWeight',          obj.fontWeight,...
                                 'fontUnits',           obj.fontUnits,...
                                 'fontSize',            obj.fontSize,...
                                 'horizontalAlignment', 'center',...
                                 'parent',              axh,...
                                 'interpreter',         obj.interpreter,...
                                 'visible',             obj.visible);

                end
                
            else
                
                for ii = 1:size(obj.colors,1)

                    % Adds a square with the color of this fan color
                    p(ii) = patch(xLocation(ii,:),yLocation,obj.colors(ii,:),...
                              'clipping',       'off',...
                              'edgecolor',      'none',...
                              'parent',         axh,...
                              'visible',        obj.visible);

                    % Adds a test to the colored square
                    t(ii) = text(xLocation(ii,1) + (xLocation(ii,3) - xLocation(ii,1))/2, yLocation(1) + 1/50,...
                                 obj.string{ii},...
                                 'fontName',            obj.fontName,...
                                 'fontWeight',          obj.fontWeight,...
                                 'fontUnits',           obj.fontUnits,...
                                 'fontSize',            obj.fontSize,...
                                 'horizontalAlignment', 'center',...
                                 'parent',              axh,...
                                 'interpreter',         obj.interpreter,...
                                 'visible',             obj.visible);

                end
                
            end
            
            obj.children = [p,t];
            
        end
        
    end
    
end
