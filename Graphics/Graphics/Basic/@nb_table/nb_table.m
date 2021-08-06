classdef nb_table < nb_plotHandle & matlab.mixin.Copyable
% Description:
%     
% This is a class for making tables.
%
% Superclasses:
% 
% nb_plotHandle, nb_cursorTracker
% 
% Constructor:
%     
%     obj = nb_table(data, varargin)
% 
%     Input:
% 
%     - data    : Table cell contents as m x n cell array
% 
%     Optional input:
%
%     - varargin : 'propertyName', propertyValue,...
% 
%     Output:
% 
%     - obj      : An object of class nb_table (handle).
%     
%     Examples:
%
%     data = asCell(nb_cs.rand);
%     t = nb_table(data);
%     t.BackgroundColor(1, :) = {'blue'};
%     
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access = public, Hidden = true)
        % Internal table cell representation. Struct array
        cells = {};
    end
    
    properties(SetAccess=protected)
        
        % A cell of the unformatted data of the table.
        data        = {};
        
    end
    
    properties
        % [R G B] or color name
        BorderColor = [0 0 0];
        
        % Normalized 1 x n vector
        ColumnSizes = [];
        
        % Round numbers to the number of digits. Default is not to round
        % numbers. Either as an integer with the number of digits, or a
        % string with the printed format. See num2str function.
        decimals    = [];
        
        % The default context menu to add to each cell. Add, Delete and
        % Format menus will be appended. If empty only these three menus
        % are added.
        defaultContextMenu
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are removed 
        % from the figure it is plotted on. If on the other hand 
        % 'only' is given, it will just delete the object.
        deleteOption = 'only'; 
        
        % Sets the language of the date format given by the DateFormat
        % property. Only important for the Monthtext and Quartertext
        % options.
        language     = 'english';
        
        % Which type of edit mode the table is in. Either 'even' (default)
        % or 'neighbour'. This affect how the rest of the rows or columns
        % of the table is resizes given the change in one of the row or
        % column. If 'even' all the rest of the rows or columns of the 
        % table share the adjustement in the row or column evenly,
        % otherwise the next row column in the line take all the
        % adjustment.
        mode         = 'even';
        
        % Normalized 1 x m vector
        RowSizes = [];
              
        % Turn automatic updates on/off. Used for performance enhancements
        % and to avoid recursion traps
        updateOnChange = false;
        
        % Boolean indicating whether or not adding/removing rows/columns is 
        % allowed
        allowDimensionChange = true;
        
        % Styling patterns. See nb_table.stylingPatternsTemplate method.
        stylingPatterns = [];
        
    end
    
    properties (Dependent = true)
        % [m n]
        size
        
        % Cell array of object handles
        children
        
        % m x n cell array. Cell contents: [R G B] | color name as string
        BackgroundColor
        
        % m x n cell array. Cell contents: [R G B] | color name as string
        Color
        
        % m x n cell array. Cell contents: cellstr
        String
        
        % m x n cell array. Cell contents: char
        DateFormat
        
        % m x n cell array. Cell contents: logical
        Editing 
        
        % m x n cell array. Cell contents: double
        FontSize
        
        % m x n cell array. Cell contents: string
        FontUnits
        
        % m x n cell array. Cell contents: 'bold' | 'normal'
        FontWeight

        % m x n cell array. Cell contents: 'left' | 'center' | 'right'
        HorizontalAlignment
        
        % m x n cell array. Cell contents: 'left' | 'center' | 'right'
        VerticalAlignment

        % m x n cell array. Cell contents: 'none' | 'tex' | 'latex'
        Interpreter
        
        % Margin from left/right border to text
        % m x n cell array. Cell contents: Integer
        Margin

        % Line width of top border
        % m x n cell array. Cell contents: Integer
        BorderTop
 
        % Line width of left border
        % m x n cell array. Cell contents: Integer
        BorderLeft

        % Line width of right border
        % m x n cell array. Cell contents: Integer
        BorderRight
        
        % Line width of bottom border
        % m x n cell array. Cell contents: Integer
        BorderBottom
        
        % Sets how many columns a cell should span.
        % Cells expand downwards and to the right.
        % m x n cell array. Cell contents: Integer
        ColumnSpan
        
        % Sets how many rows a cell should span
        % Cells expand downwards and to the right.
        % m x n cell array. Cell contents: Integer
        RowSpan
    end
    
    properties (Access = protected)       
        % Used for detecting dragging of column/row dividers
        % see methods onMouseDown, onMouseUp and getHoveredDividers
        selectedColumnDivider  = [];
        selectedRowDivider     = [];
        selectionStartPosition = []; 
        
        % Graphic handles
        contextMenu         = [];
        contextMenuAdd      = [];
        contextMenuDelete   = [];
        contextMenuFormat   = [];
        contextMenuTemplate = [];
        axesHandle          = [];
        
        % Selected text object for editing
        editedObject = [];
        editIndex    = [];
        
        % Reference to the listeners
        listeners    = [];
        
        firstPlot = true;
    end
    
    properties (Access = public, Hidden = true)
        % Needed by nb_axes parent
        side = 'left';
        type = 'table';
        % Needed by the whenused in DAG
        gui  = [];
    end
    
    events
        
        tableUpdate
        tableStyleUpdate
        tableTextUpdate
       
    end
       
    methods
        
        function set.BorderColor(obj,value)
            if ~nb_isColorProp(value)
                error([mfilename ':: The BorderColor property must'  ...
                                 ' must have dimension size'         ...
                                 ' size(plotData,2) x 3 with the RGB'...
                                 ' colors or a cellstr with size 1 x'...
                                 ' size(yData,2) with the color names.'])
            end
            obj.BorderColor = value;
        end
        
        function set.ColumnSizes(obj,value)
            if ~ismember(size(value,1),1)
                if ~ismember(size(value',1),1) 
                    error([mfilename ':: The ColumnSizes property must be a'...
                     ' row vector.'])
                end
                value = value';
            end
            if ~isa(value,'double')
               error([mfilename ':: The ColumnSizes property must be a'...
                     ' row vector.'])
            end
            obj.ColumnSizes = value;
        end
        
        function set.decimals(obj,value)
            if ~nb_isScalarNumber(value) && ~nb_isOneLineChar(value)
               error([mfilename ':: The decimals property must be an'...
                     ' integer or a one line char.'])
            end
            obj.decimals = value;
        end
        
        function set.defaultContextMenu(obj,value)
            if ~nb_isOneLineChar(value) && ...
                            ~isa(value,'matlab.ui.container.ContextMenu') && ~isempty(value)
               error([mfilename ':: The defaultContextMenu property must'...
                    ' be one line char or a ContextMenu object'])
            end
            obj.defaultContextMenu = value;
        end
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'only','all'},value)) 
               error([mfilename ':: The deleteOption property must'...
                    ' be either ''only'' or ''all''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.language(obj,value)
            if ~nb_isOneLineChar(value) 
               error([mfilename ':: The language property must'...
                    ' be given as a one line char.'])
            end
            obj.language = value;
        end
        
        function set.mode(obj,value)
            if ~any(strcmp({'neighbour','even'},value)) 
               error([mfilename ':: The mode property must'...
                    ' be either ''neighbour'' or ''even''.'])
            end
            obj.mode = value;
        end
        
        function set.RowSizes(obj,value)
            if ~ismember(size(value,1),1)
                if ~ismember(size(value',1),1) 
                    error([mfilename ':: The RowSize property must be a'...
                     ' row vector.'])
                end
                value = value';
            end
            if ~isa(value,'double')
               error([mfilename ':: The RowSizes property must be a'...
                     ' row vector.'])
            end
            obj.RowSizes = value;
        end           

        function set.updateOnChange(obj,value)
            if ~nb_isScalarLogical(value)
               error([mfilename ':: The updateOnChange property must'...
                    ' be set to either true or false.'])
            end
            obj.updateOnChange = value;
        end
        
        function set.allowDimensionChange(obj,value)
            if ~nb_isScalarLogical(value)
               error([mfilename ':: The allowDimensionChange property must'...
                    ' be set to either true or false.'])
            end
            obj.allowDimensionChange  = value;
        end       
        
        function set.stylingPatterns(obj,value)
            if ~nb_isOneLineChar(value) && ~isstruct(value)
               error([mfilename ':: The stylingPatterns property must'...
                    ' be set to a one line char or given as a struct.'])
            end
            obj.stylingPatterns = value;
        end  
                
        function obj = nb_table(data, varargin)
            
            if nargin < 1
                data = asCell(nb_cs.rand(5, 5));
            end
            
            if ~iscell(data)
                data = asCell(data);
            end
                      
            % Create cells
            obj.cells = nb_table.defaultCells(size(data));
            
            % Fill with data
            obj.String = data;
            
            % Default row and column sizes
            obj.RowSizes    = ones(1, size(data,1)) / size(data,1);
            obj.ColumnSizes = ones(1, size(data,2)) / size(data,2);
            
            % Default style
            obj.stylingPatterns = nb_table.stylingPatternsTemplate('nb');
            
            % Optional arguments
            obj.set(varargin);
          
            % obj.updateOnChange = true;
            
        end  
        
    end
    
    % Public methods
    methods (Access = public)
        varargout = plot(varargin);
        varargout = update(varargin);
        
        varargout = set(varargin)
        varargout = get(varargin)

        varargout = addRow(varargin);
        varargout = addColumn(varargin);
        varargout = deleteRow(varargin);
        varargout = deleteColumn(varargin);
        
        varargout = colormap(varargin);
        
        varargout = delete(varargin);
        varargout = deleteChildren(varargin);
    end
    
    methods(Access = public, Hidden = true)
        
        varargout = changeMouse(varargin);
        
        function ylimit = findYLimits(obj) %#ok<MANU>
            ylimit = [0,1];
        end
        
        function xlimit = findXLimits(obj) %#ok<MANU>
            xlimit = [0,1]; 
        end
        
    end
       
    methods (Access = public)
        % Graphics creation
        varargout = createCells(varargin);
        varargout = updateCells(varargin);
        varargout = createContextMenu(varargin);
        varargout = createCellGraphics(varargin);
        
        % Draggable row/column dividers
        varargout = getHoveredDividers(varargin);
        varargout = onMouseUp(varargin);
        varargout = onMouseDown(varargin);
        
        % Callbacks
        varargout = addColumnCallback(varargin);
        varargout = addRowCallback(varargin);
        varargout = editText(varargin);
        varargout = formatGUI(varargin);
        
        varargout = finishEditing(varargin);
    end
    
    methods (Access = protected)
        
        function copyObj = copyElement(obj)
        % Overide the copyElement method of the 
        % matlab.mixin.Copyable class to remove some  
        % handles
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            copyObj.parent            = [];
            copyObj.axesHandle        = [];
            copyObj.contextMenu       = [];
            copyObj.contextMenuAdd    = [];
            copyObj.contextMenuDelete = [];
            copyObj.contextMenuFormat = [];
            copyObj.contextMenuTemplate = [];
            s = struct('background',    nan,...
               'text',          nan,...
               'borderTop',     nan,...
               'borderRight',   nan,...
               'borderBottom',  nan,...
               'borderLeft',    nan);
            [copyObj.cells.graphicHandles] = deal(s);
               
        end
        
    end
    
    % Getter methods
    methods
        function value = get.size(obj)
            value = obj.get('size');
        end
        
        function value = get.children(obj)
            value = obj.get('children');
        end

        function value = get.Color(obj)
           value = obj.get('Color'); 
        end

        function value = get.BackgroundColor(obj)
           value = obj.get('BackgroundColor'); 
        end

        function value = get.DateFormat(obj)
           value = obj.get('DateFormat'); 
        end
        
        function value = get.FontSize(obj)
           value = obj.get('FontSize'); 
        end
        
        function value = get.Editing(obj)
           value = obj.get('Editing'); 
        end
        
        function value = get.FontUnits(obj)
           value = obj.get('FontUnits'); 
        end
        
        function value = get.FontWeight(obj)
           value = obj.get('FontWeight'); 
        end
       
        function value = get.HorizontalAlignment(obj)
           value = obj.get('HorizontalAlignment'); 
        end
        
        function value = get.VerticalAlignment(obj)
           value = obj.get('VerticalAlignment'); 
        end
        
        function value = get.Interpreter(obj)
           value = obj.get('Interpreter'); 
        end
        
        function value = get.Margin(obj)
           value = obj.get('Margin'); 
        end

        function value = get.String(obj)
           value = obj.get('String'); 
        end
        
        function value = get.BorderTop(obj)
           value = obj.get('BorderTop'); 
        end
        
        function value = get.BorderLeft(obj)
           value = obj.get('BorderLeft'); 
        end
        
        function value = get.BorderRight(obj)
           value = obj.get('BorderRight'); 
        end
        
        function value = get.BorderBottom(obj)
           value = obj.get('BorderBottom'); 
        end
        
        function value = get.ColumnSpan(obj)
           value = obj.get('ColumnSpan'); 
        end
        
        function value = get.RowSpan(obj)
           value = obj.get('RowSpan'); 
        end
    end
    
    % Setter methods
    %
    % Examples:
    % t.BackgroundColor(:, 2) = {'blue'};
    methods
        function set.String(obj, value)
            obj.set('String', value);
        end
        
        function set.Color(obj, value)
            obj.set('Color', value);
        end
        
        function set.BackgroundColor(obj, value)
            obj.set('BackgroundColor', value);
        end
        
        function set.Editing(obj, value)
            obj.set('Editing', value);
        end
        
        function set.FontWeight(obj, value)
            obj.set('FontWeight', value);
        end
        
        function set.HorizontalAlignment(obj, value)
            obj.set('HorizontalAlignment', value);
        end
        
        function set.VerticalAlignment(obj, value)
            obj.set('VerticalAlignment', value);
        end
        
        function set.Interpreter(obj, value)
            obj.set('Interpreter', value);
        end
        
        function set.Margin(obj, value)
            obj.set('Margin', value);
        end
        
        function set.BorderTop(obj, value)
            obj.set('BorderTop', value);
        end
        
        function set.BorderLeft(obj, value)
            obj.set('BorderLeft', value);
        end
        
        function set.BorderRight(obj, value)
            obj.set('BorderRight', value);
        end
        
        function set.BorderBottom(obj, value)
            obj.set('BorderBottom', value);
        end
        
        function set.ColumnSpan(obj, value)
            obj.set('ColumnSpan', value);
        end
        
        function set.RowSpan(obj, value)
            obj.set('RowSpan', value);
        end
    end
    
    methods (Static = true)
        
        varargout = defaultCells(varargin)
        
        varargout = defaultCellStyles(varargin)
        
        varargout = stylingPatternsTemplate(varargin)
        
        varargout = mergeCells(varargin)
        
        varargout = unstruct(varargin)
        
        varargout = convertCursorIndex(varargin);
        
    end
    
end
