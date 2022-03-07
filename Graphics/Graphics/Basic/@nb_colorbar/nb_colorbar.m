classdef nb_colorbar < nb_annotation & nb_textAnnotation
% Superclasses:
% 
% nb_annotation, handle
%     
% Description:
%     
% A class for adding color bar to a plot (axes).
%     
% Constructor:
%     
%     obj = nb_colorbar(varargin)
%     
%     Input:
% 
%     Optional input ('propertyName', propertyValue):
%
%     > You can set some properties of the class. See the list 
%       below. 
%     
%     Output
% 
%     - obj      : An object of class nb_colorbar
%     
% See also:
% nb_annotation, handle, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
        
        % Direction of the color bar. 'normal' or 'reverse'.
        direction   = 'normal';
        
        % Invert color map when applied to the color bar. true or
        % false. Default is false.
        invert      = false;
        
        % Sets the language of the text. I.e. how decimal sign 
        % should be plotted. {'english'} | 'norwegian'.
        language    = 'english'; 
        
        % The location of the color bar. See the MATLAB function colorbar
        % for more on the values to choose from. Default is 'eastOutside'.
        location    = 'eastOutside';
        
        % Extra space added between color bar and the assosiated axes.
        % Positive scalar number.
        space       = 0;
        
        % Strip colors from the color map of the parent to be in the
        % color bare. Default is to strip [1,1,1] (white). Must be a
        % N x 3 double.
        strip       = [];
        
        % Tick mark labels, specified as a cell array of character vectors, 
        % a string array, a numeric array, a character vector, or a 
        % categorical array. By default, the colorbar labels the tick 
        % marks with numeric values taken from the data of the imageChild
        % of the nb_axes the colorbar is attached to. If this property is
        % empty (no image added to the axes), a default [0,1] scale is
        % given.
        tickLabels  = {};
        
        % Tick mark locations, specified as a vector of monotonically 
        % increasing numeric values. The values do not need to be equally 
        % spaced. If you do not want tick marks displayed, then set the 
        % property to the empty vector, [].
        ticks       = [];
        
        ID
        
    end
    
    properties (SetAccess=protected)
        
        tickLabelsSet = false;
        ticksSet      = false;
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_colorbar(varargin)
        % Constructor
        
            if nargin > 0 
                set(obj,varargin);
            end
            obj.ID = java.rmi.server.UID();
                 
        end
        
        varargout = set(varargin)
        
        function update(obj)
            plot(obj);
        end
          
    end
    
    methods(Access=public,Hidden=true)
        
        function s = struct(obj)
            s     = struct('class', 'nb_colorbar');
            props = properties(obj);
            props = setdiff(props,{'parent'});
            for ii = 1:length(props)
                s.(props{ii}) = obj.(props{ii});
            end
            s.tickLabelsSet = obj.tickLabelsSet;
            s.ticksSet      = obj.ticksSet;
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        function plot(obj)
            
            % The colorbar class by MATLAB does not support fontUnits,
            % so we need to convert to 'points'
            oldUnits      = obj.fontUnits;
            obj.fontUnits = 'points';
            setFontSize(obj,oldUnits);
            
            % Get the parent to plot on
            %------------------------------------------------------
            ax = obj.parent;
            if isempty(ax)
                return
            end
            if ~isvalid(ax) 
                return
            end
            
            % Delete the old object plotted by this object
            obj.deleteChildren();

            % Get parent of axes
            if isa(ax.parent,'nb_graphPanel')
                figHandle = ax.parent.panelHandle;
            else
                figHandle = ax.parent.figureHandle;
            end
            
            % Create an axes for this color bar alone
            axesHandle = axes(...
               'units',     ax.units,...
               'color',     'none',...
               'parent',    figHandle,...
               'position',  ax.position,...
               'units',     'normalized',...
               'visible',   'off');
           
            % Get the ticks and tick labels
            if obj.tickLabelsSet
                tickMarkLabels = obj.tickLabels;
            else
                if isempty(ax.imageChild)
                    minObs = 0;
                    maxObs = 1;
                else
                    maxObs = max(ax.imageChild.cData(:));
                    minObs = min(ax.imageChild.cData(:));
                end
                
                % Find MATLAB selected tick labels
                p              = plot(axesHandle,[minObs, maxObs]);
                tickMarkLabels = get(axesHandle,'yTickLabels');
                delete(p);
            end
            if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
                tickMarkLabels = strrep(tickMarkLabels,'.',',');
            end
           
            % Remove axis itself
            axis(axesHandle,'off');
            
            % Get color map from the parent
            ind = cellfun(@(x)isa(x,'nb_gradedFanChart'),ax.children);
            if any(ind)
                cMap = ax.children{ind}.cData;
            else
                cMap = getColorMap(ax);
            end
            if ~isempty(obj.strip)
                cMap = setdiff(cMap,obj.strip,'rows','stable');
            end
            if obj.invert
                cMap = flipud(cMap);
            end
            
            % Set the colormap of an axes handle that is not used for 
            % plotting, so does not mather.
            colormap(axesHandle,cMap);
            
            % If the font size is normalized we get the font size
            % transformed to another units
            if strcmpi(obj.fontUnits,'normalized')
                if strcmpi(obj.normalized,'axes')
                    fontS = obj.fontSize;
                else % figure
                    fontS = obj.fontSize*0.8/ax.position(4);
                end
            else
                fontS = obj.fontSize;
            end
            
            if obj.ticksSet
                tickMarks = obj.ticks;
            else
                tickMarks = linspace(0,1,length(tickMarkLabels))';
            end
            
            % Do the plotting
            obj.children = colorbar(axesHandle,...
                'direction',   obj.direction,...
                'fontName',    obj.fontName,...
                'fontWeight',  obj.fontWeight,...
                'fontSize',    fontS,...
                'location',    obj.location,...
                'tickLabels',  tickMarkLabels,...
                'ticks',       tickMarks');
            drawnow;
            pos = get(axesHandle,'position');
            set(ax.axesHandle,'position',pos);
            set(ax.axesHandleRight,'position',pos);
            set(ax.shadingAxes,'position',pos);
            set(ax.plotAxesHandle,'position',pos);
            set(ax.plotAxesHandleRight,'position',pos);
            set(ax.axesLabelHandle,'position',pos);
            
            % Move color bar
            if obj.space ~= 0
                pos    = get(obj.children,'position');
                pos(1) = pos(1) + obj.space;
                set(obj.children,'position',pos);
            end
            
            % Add a uicontext menu to the arrow
            %------------------------------------------------------
            cMenu = uicontextmenu('parent',ax.parent.figureHandle); 
                 uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
                 uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
            set(obj.children,'UIContextMenu',cMenu)         
  
            % Merge axes with children
            obj.children = [axesHandle,obj.children];
            
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the text
        % handle
            
            nb_editColorBar(obj);
        
        end
        
        function deleteCallback(obj,~,~)
        % Callback function called when user click on the delete 
        % option of the uicontextmenu handle attached to the text
        % handle 
        
            nb_confirmWindow('Are you sure you want to delete the selected object?',@notDelete,{@deleteAnnotation,obj},'Delete Annotation');
            
            function deleteAnnotation(hObject,~,obj)
        
                obj.deleteOption = 'all';
                delete(obj);
                
                % Close question window
                close(get(hObject,'parent'));
                
            end

            function notDelete(hObject,~)

                % Close question window
                close(get(hObject,'parent'));

            end
  
        end
        
    end
    
    methods (Static=true,Hidden=true)
        
        function obj = unstruct(s)
            obj    = nb_colorbar();
            fields = fieldnames(s);
            fields = setdiff(fields,{'class'});
            for ii = 1:length(fields)
                obj.(fields{ii}) = s.(fields{ii});
            end
        end
        
    end
    
end
