classdef nb_graphPanel < nb_figure
% Syntax:
%     
% obj = nb_graphPanel(varargin)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% This is class for creating a graph panel, which will have a 
% resize behavioral to keep the font size fixed proportion to
% the axes (as nb_axes object) of the panel.
%
% Caution : The panel will be centralized in the figure!
%
% Constructor:
%     
%     obj = nb_graphPanel(aspectRatio,varargin)
%     
%     Input: 
% 
%     - aspectRatio : Sets the aspect ratio of the graph panel.
%                     Must be a scalar. Give [], if you want to
%                     use the default.
%
%     - varargin    : ...,'propertyName',propertyValue,...
%     
%     Output
% 
%     - obj      : An object of class nb_graphPanel
%     
%     Examples:
% 
%     nb_graphPanel
%     obj = nb_graphPanel(aspectRatio)
%     obj = nb_graphPanel(aspectRatio,...
%                         'propertyName',propertyValue,...)
%     
% See also:  
% nb_figure, nb_axes      
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Sets the aspect ratio of the graph panel. Default is
        % '[4,3]'
        aspectRatio         = '[4,3]';
        
        % Handle to the uipanel object of the nb_graphPanel object.
        panelHandle         = [];
        
        % Indicate if advanced figure is made.
        advanced            = 0;
        
    end
    
    methods
        
        function set.aspectRatio(obj,value)
            if ~(nb_isOneLineChar(value) || isempty(value))
                error([mfilename ':: The aspectRatio property must be '...
                      'as a one line character array.'])
            end
            obj.aspectRatio = value;
        end   
        
        function set.advanced(obj,value)
            if ~any(ismember([1,0],value))
                error([mfilename ':: The advanced property must be '...
                      'given either 1 or 0.'])
            end
            obj.advanced = value;
        end    
        
        function obj = nb_graphPanel(aspectRatio,varargin)
        % Constructor of the nb_graphPanel class
        
            if nargin < 1
                aspectRatio = '[4,3]';
            end
            
            ind = find(strcmpi('advanced',varargin));
            adv = 0;
            for ii = 1:size(ind,2)
                adv      = varargin{ind(ii) + 1};
                varargin = [varargin(1:ind(ii)-1), varargin(ind(ii)+2:end)];
            end
            
            % Call the superclass constructor
            obj@nb_figure(varargin{:});
            set(obj,'units','characters');
            obj.advanced = adv;
            
            % Get properties from the figure handle
            c   = get(obj.figureHandle,'color');
            
            % Create the uipanel with the same size as the figure
            p   = uipanel('parent',              obj.figureHandle,...
                          'backgroundColor',     c,...
                          'borderType',          'none',...
                          'units',               'normalized',...
                          'position',            [0,0,1,1],...
                          'userData',           'uipanel');
            set(p,'units','characters'); 
            
            % Assign properties
            obj.panelHandle = p;
            obj.aspectRatio = aspectRatio;
            
            % Add resize callback function to the figure handle
            set(obj.figureHandle,'resizeFcn',{@nb_graphPanel.resizeFcn,obj})

        end
        
        varargout = set(varargin)
        varargout = get(varargin)
 
        %{
        -------------------------------------------------------------------
        Delete the nb_figure object
        -------------------------------------------------------------------
        %}
        function delete(obj)
            
            % Delete all the nb_axes properties of the object 
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
                
            end
                         
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected,Hidden=true)
        
          
    end
    
    methods (Access=protected,Hidden=true,Static=true)
        
        function resizeFcn(hObject,~,obj)
        % Define a resize function which keeps the aspect ratio
        % of the uipanel handle of the figure handle
        %
        % Caution: we assume that the units of the figure is in
        % characters
            
            if isempty(obj.aspectRatio)
                % Cover full figure.
                nb_setInUnits(findobj(hObject,'userData','uipanel'),...
                    'position',[0,0,1,1],'normal');
                obj.notify('resized');
                return
            end
            if obj.advanced 
                ratio = '[4,3]';
                lowestX = 130.8; 
                lowestY = 28.8962;
            else
                ratio = obj.aspectRatio;
                if strcmpi(ratio,'[16,9]')
                    lowestX = 81; 
                    lowestY = 17.8462;
                elseif strcmpi(ratio,'[4,3]')
                    lowestX = 81; 
                    lowestY = 17.8462;
                end
            end
        
            % Get figure position in characters
            uip = findobj(hObject,'userData','uipanel');
            pos = get(hObject,'position');
            
            % Figure sizes
            widthF  = pos(3);
            heightF = pos(4);
            
            if widthF < lowestX && heightF < lowestY
                set(hObject,'position',[pos(1,1:2),lowestX,lowestY]);
                widthF  = lowestX;
                heightF = lowestY;
            elseif widthF < lowestX 
                set(hObject,'position',[pos(1,1:2),lowestX,pos(4)]);
                widthF  = lowestX;
            elseif heightF < lowestY
                set(hObject,'position',[pos(1,1:3),lowestY]);
                heightF = lowestY;
            end
            
            if strcmpi(ratio,'[4,3]')
                
                % Find the new position
                if obj.advanced
                    table = [334.4, 73.7692;
                             217.4, 47.7692;
                             130.8, 28.8962];
                else
                    table = [341,   75.1334;
                             292,   64.3077;
                             250,   55.0418; 
                             185,   40.6923;
                             130,   28.6154;
                             108,   23.5385;
                              81,   17.8462];
                end
                      
                indW   = find(widthF >= table(:,1),1);      
                indH   = find(heightF >= table(:,2),1);       
                ind    = max(indW,indH);
                if isempty(ind)
                    ind = 5;
                end
                width  = table(ind,1);
                height = table(ind,2);
                
                % Centralize the panel in the figure
                ystart = (heightF - height)/2;
                xstart = (widthF - width)/2; 
                
            elseif strcmpi(ratio,'[16,9]')
                
                % Find the new position
                table = [276.8333,  33;
                         183.3333,  25;
                         114.1667,  15.75;
                         69.3333,   9.375];
                      
                indW   = find(widthF >= table(:,1),1);      
                indH   = find(heightF >= table(:,2),1);       
                ind    = max(indW,indH);
                if isempty(ind)
                    ind = 4;
                end
                width  = table(ind,1);
                height = table(ind,2);
                
                % Centralize the panel in the figure
                ystart = (heightF - height)/2;
                xstart = (widthF - width)/2; 
                
            else % Aspect ratio is continuous
            
                % Get uipanel position in characters
                posUip = get(uip,'position');

                % Keep aspect ratio
                width  = posUip(3);
                height = posUip(3)*0.22;

                % Scale to fit figure window
                xScale      = widthF/width;
                yScale      = heightF/height;
                [scale,ind] = min([xScale,yScale]);
                width       = width*scale;
                height      = height*scale;

                % Centralize the panel in the figure
                if ind == 1
                     xstart = 0;
                     ystart = (heightF - height)/2;
                else
                     xstart = (widthF - width)/2; 
                     ystart = 0;
                end
            
            end
            
            % Set its found position
            set(uip,'position',[xstart,ystart,width,height]);
            
            obj.notify('resized');
            
        end
          
    end
       
end
