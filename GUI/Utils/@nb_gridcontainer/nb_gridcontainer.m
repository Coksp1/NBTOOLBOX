classdef nb_gridcontainer < handle
% Description:
%
% Replacement for uigridcontainer
%
% A few differences:
% - parent must be given as first argument
% - update method must be called after toggling child visibility
% - Padding option to specifically set the outer margin
%
% Constructor:
%
%   obj = nb_gridcontainer(parent, varargin)
%
%   Input:
%
%   - parent : A figure object.
% 
%   Examples:
%
%   parent = figure();
%   grid   = nb_gridcontainer(parent, 'GridSize', [2 2], 'Margin', 10);
%   uicontrol(grid, 'Style', 'edit', 'String', 'Upper left');
%   uicontrol(grid, 'Style', 'edit', 'String', 'Upper right');
%   uicontrol(grid, 'Style', 'edit', 'String', 'Bottom left');
%   uicontrol(grid, 'Style', 'edit', 'String', 'Bottom right');
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (SetAccess = protected)
        % [numOfRows, numOfColumns]
        GridSize = [1 1];
        
        % Spacing between grid cells in pixels. A scalar or 1x2 double.
        Margin = 2;
        
        % Outer margin in pixels. If set to [], it defaults to Margin.
        % A scalar or 1x2 double.
        Padding = [];
        
        % Weights for column widhts as a 1 x numOfCols vector.
        % If set to [], it defaults to even-sized columns
        HorizontalWeight = [];
        
        % Weights for row heights as a 1 x numOfRows vector.
        % If set to [], it defaults to even-sized rows
        VerticalWeight = [];
    end
    
    properties (SetAccess = protected)
        % Underlying uipanel
        panel
    end
    
    properties (Access = protected)
        children
        
        % Properties available for get/set
        gridProps
        panelProps
        
        columnSizes
        columnPositions
        rowSizes
        rowPositions
    end
    
    properties (Access = protected, Dependent)
        visibleChildren
    end
    
    methods
        
        function obj = nb_gridcontainer(parent, varargin)
            
            if nargin == 0
                return
            end
            
            if ~isscalar(parent) || (~ishandle(parent) && ~isobject(parent))
                error('First argument must be the parent handle.');
            end
            
            % Nested nb_gridcontainer?
            if isa(parent, 'nb_gridcontainer')
                obj = nb_gridcontainer_child(parent, varargin{:});
                return;
            end
            
            obj.panel = uipanel(parent, ...
                'BorderWidth', 0, ...
                'ResizeFcn', @obj.update);
            
            obj.gridProps  = nb_gridcontainer.caseMap(properties(obj));
            obj.panelProps = nb_gridcontainer.caseMap(fieldnames(get(obj.panel)));
            
            obj.set(varargin{:});
        end
        
        function value = get(obj, prop)
            prop = lower(prop);

            if isfield(obj.gridProps, prop)
                gridProp = obj.gridProps.(prop);
                value = obj.(gridProp);
            elseif isfield(obj.panelProps, prop)
                panelProp = obj.panelProps.(prop);
                value = get(obj.panel, panelProp);
            elseif strcmpi(prop,'children')
                value = obj.children;
            else
                error(['No public field ' prop ' exists for class nb_gridcontainer.']);
            end
        end
        
        function set(obj, varargin)
            
            if numel(obj) > 1
                obj = obj(:);
                for ii = 1:size(obj,1)
                    set(obj(ii), varargin{:});
                end
                return
            end
            
            inputProps     = nb_gridcontainer.parseOptions(varargin{:});
            inputPropNames = fieldnames(inputProps);
            
            for i = 1:length(inputPropNames)
                prop = inputPropNames{i};
                value = inputProps.(prop);
                
                if isfield(obj.gridProps, prop)
                    gridProp = obj.gridProps.(prop);
                    obj.(gridProp) = value;
                elseif isfield(obj.panelProps, prop)
                    panelProp = obj.panelProps.(prop);
                    set(obj.panel, panelProp, value);
                else
                    error(['No public field ' prop ' exists for class nb_gridcontainer.']);
                end
            end 
            obj.update();
            
        end
        
        function value = get.VerticalWeight(obj)
            value = obj.VerticalWeight;
            
            % Default to even rows
            if isempty(value)
                value = ones(obj.GridSize(1), 1);
            end
            value = value(:) ./ sum(value);
            
        end
        
        function value = get.HorizontalWeight(obj)
            value = obj.HorizontalWeight;
            
            % Default to even columns
            if isempty(value)
                value = ones(obj.GridSize(2), 1);
            end
            value = value(:) ./ sum(value);
            
        end
        
        function value = get.Padding(obj)
            
            value = obj.Padding;
            if isempty(value)
                value = obj.Margin;
            end
            
        end
        
        function children = get.visibleChildren(obj)
            
           children = obj.children;
           for i = length(children):-1:1
               if strcmpi(get(children(i), 'Visible'), 'off')
                   children(i) = [];
               end
           end
           
        end
        
        function child = uicontrol(obj, varargin)
            child = obj.addChild(@uicontrol, varargin{:});
        end
        
        function child = uibuttongroup(obj, varargin)
            child = obj.addChild(@uibuttongroup, varargin{:});
        end
        
        function child = uitable(obj, varargin)
            child = obj.addChild(@uitable, varargin{:});
        end
        
        function child = uitree(obj, varargin)
            child = obj.addChild(@uitree, varargin{:});
        end
        
        function child = nb_uitable(obj, varargin)
            child = obj.addChild(@nb_uitable, varargin{:});
        end
        
        function child = nb_gridcontainer_child(obj, varargin)
            child = obj.addChild(@nb_gridcontainer, varargin{:});
        end
        
        function update(obj, varargin)
            if isempty(obj.panel)
                return
            end
            obj.calculatePositions();
            for i = 1:length(obj.visibleChildren)
                set(obj.visibleChildren(i), ...
                   'Units', 'normalized', ...
                   'Position', obj.getPositionOfChild(i));
            end
        end
        
    end
    
    methods (Access = protected)
        
        function child = addChild(obj, constructor, varargin)
            
            props       = nb_gridcontainer.parseOptions(varargin{:});
            props.units = 'normalized';
            
            numOfVisibleChildren = length(obj.visibleChildren);
            if (numOfVisibleChildren < prod(obj.GridSize))
                numOfVisibleChildren = numOfVisibleChildren + 1;
                props.position       = obj.getPositionOfChild(numOfVisibleChildren);
            else
                props.visible = 'off';
            end
            if isfield(props,'uicontextmenu')
                fig     = nb_getParentRecursively(obj.panel);
                figMenu = get(props.uicontextmenu,'parent');
                if fig ~= figMenu
                    set(props.uicontextmenu,'parent',fig);
                end
            end
            
            propsArray  = nb_struct2cellarray(props);
            child       = constructor(obj.panel, propsArray{:});
            childHandle = child;
            if isa(child, 'nb_gridcontainer')
                childHandle = get(child, 'panel');
            elseif isa(child, 'nb_uitable')
                childHandle = child.table;
            end
            obj.children(end + 1) = childHandle;
            
        end
        
        function calculatePositions(obj)
            
            numOfRows       = obj.GridSize(1);
            numOfCols       = obj.GridSize(2);
            horizontalSizes = zeros(numOfCols + (numOfCols + 1), 1);
            verticalSizes   = zeros(numOfRows + (numOfRows + 1), 1);
            pixelToNorm     = nb_unitsRatio('pixels', 'normalized', obj.panel);
            
            % Margin
            marginInNormalizedUnits = obj.Margin .* pixelToNorm;
            marginX = marginInNormalizedUnits(1);
            marginY = marginInNormalizedUnits(2);
            
            horizontalSizes(1:2:end) = marginX;
            verticalSizes(1:2:end)   = marginY;
            
            % Padding (outer margin)
            paddingInNormalizedUnits = obj.Padding .* pixelToNorm;
            paddingX                 = paddingInNormalizedUnits(1);
            paddingY                 = paddingInNormalizedUnits(2);
            
            horizontalSizes(1)   = paddingX;
            horizontalSizes(end) = paddingX;
            verticalSizes(1)     = paddingY;
            verticalSizes(end)   = paddingY;
            
            horizontalSizes(2:2:end) = obj.HorizontalWeight(1:numOfCols) .* (1 - sum(horizontalSizes));
            verticalSizes(2:2:end)   = obj.VerticalWeight(1:numOfRows) .* (1 - sum(verticalSizes));
            
            obj.columnSizes     = horizontalSizes;
            obj.columnPositions = [0; cumsum(horizontalSizes(1:end - 1))];
            obj.rowSizes        = verticalSizes;
            obj.rowPositions    = 1 - cumsum(verticalSizes);
            
        end
        
        function position = getPositionOfChild(obj, index) 
            
            [col, row] = ind2sub(fliplr(obj.GridSize), index);          
            position   = [...
                obj.columnPositions(2 * col), ...
                obj.rowPositions(2 * row), ...
                obj.columnSizes(2 * col), ...
                obj.rowSizes(2 * row)];
            position(position <= 0) = eps;
            
        end
        
    end
    
    methods (Static)
        varargout = caseMap(varargin);
        varargout = parseOptions(varargin);
        varargout = test(varargin);
    end
end
