function formatGUI(obj, ~, ~, range)
% Show formatting window

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the handle to the main program
    mainGUI = obj.gui;

    % Get cell position
    [y, x] = obj.getGridPosition(gco);

    % Figure
    figureHandle = nb_guiFigure(mainGUI,'Formatting',[65,   15,  75,   30],'normal','off');

    grid = nb_gridcontainer(figureHandle,...
        'Position', [0 0 1 1],...
        'Margin', 10,...
        'GridSize', [14, 2]);
    
    labelProps = nb_constant.LABEL;
    editProps = nb_constant.EDIT;
    popupProps = nb_constant.POPUP;
    
    % Get property values where all selected cells agree
    switch lower(range)
        case 'table'
            properties = getCommonProperties(obj.cells(:));
        case 'row'
            properties = getCommonProperties(obj.cells(y, :));
        case 'column'
            properties = getCommonProperties(obj.cells(:, x));
        otherwise
            properties = obj.cells(y, x);
    end
    
    defaultColors = nb_defaultColors();
    defaultColors = [defaultColors;[117 143 173] / 255;[1,1,1]];
    
    % Background color
    uicontrol(grid, labelProps, 'String', 'Background color');    
    bgColors = [NaN NaN NaN; properties.BackgroundColor; defaultColors];
    bgColorsHTML = [cellstr(''); htmlColors(bgColors(2:end, :))];
    bgColor = 1;
    if ~isempty(properties.BackgroundColor)
        bgColor = 2;
    end
    backgroundColorBox = uicontrol(grid, popupProps, ...
        'string', bgColorsHTML, ...
        'value', bgColor);
    
    % Date format
    uicontrol(grid, labelProps, 'String', 'Date format');
    dateFormats = {'','dd.mm.yyyy', 'Monthtext yyyy','yyyy','qQuartertext yyyy','qQuartertext',...
                   'Weektext w(w) yyyy','Monthtext','d(d). monthtext yyyy','d(d). Monthtext yyyy'};
    dateFormat = 1;
    if ~isempty(properties.DateFormat)
        dateFormat = find(ismember(dateFormats, properties.DateFormat));
    end
    dateFormatBox = uicontrol(grid, popupProps, ...
        'string', dateFormats,...
        'value', dateFormat);
    
    % Font color
    uicontrol(grid, labelProps, 'String', 'Font Color'); 
    fontColors = [NaN NaN NaN; properties.Color; defaultColors];
    fontColorsHTML = [cellstr(''); htmlColors(fontColors(2:end, :))];
    fontColor = 1;
    if ~isempty(properties.Color)
        fontColor = 2;
    end
    colorBox = uicontrol(grid, popupProps, ...
        'string', fontColorsHTML, ...
        'value', fontColor);
    
    % Font Weight
    uicontrol(grid, labelProps, 'String', 'Font Weight');
    fontWeights = {'', 'Normal', 'Bold'};
    fontWeight = 1;
    if ~isempty(properties.FontWeight)
        fontWeight = find(ismember(lower(fontWeights), lower(properties.FontWeight)));
    end
    fontWeightBox = uicontrol(grid, popupProps, ...
        'string', fontWeights,...
        'value', fontWeight);
    
    % Font Interpreter
    uicontrol(grid,labelProps,'String', 'Font Interpreter');
    fontInts = {'','none', 'tex'};
    fontInt  = 1;
    if ~isempty(properties.Interpreter)
        fontInt = find(ismember(lower(fontInts), lower(properties.Interpreter)));
    end
    fontIntBox = uicontrol(grid, popupProps, ...
        'string', fontInts,...
        'value',  fontInt);
    
    % Horizontal alignment
    uicontrol(grid, labelProps, 'String', 'Horizontal alignment');
    horizontalAlignments = {'Left', 'Center', 'Right'};
    if ~isempty(properties.HorizontalAlignment)
        horizontalAlignment = find(ismember(...
            lower(horizontalAlignments), ...
            lower(properties.HorizontalAlignment)));
    else
        horizontalAlignments = [{''}, horizontalAlignments];
        horizontalAlignment = 1;
    end
    horizontalAlignmentBox = uicontrol(grid, popupProps, ...
        'string', horizontalAlignments,...
        'value', horizontalAlignment);
    
    % Vertical alignment
    uicontrol(grid, labelProps, 'String', 'Vertical alignment');
    verticalAlignments = {'Top', 'Cap', 'Middle', 'Baseline', 'Bottom'};
    if ~isempty(properties.VerticalAlignment)
        verticalAlignment = find(ismember(...
            lower(verticalAlignments), ...
            lower(properties.VerticalAlignment)));
    else
        verticalAlignments = [{''}, verticalAlignments];
        verticalAlignment = 1;
    end
    verticalAlignmentBox = uicontrol(grid, popupProps, ...
        'string', verticalAlignments, ...
        'value', verticalAlignment);
    
    % Column and row span
    uicontrol(grid, labelProps, 'String', 'Column span');
    columnSpanBox = uicontrol(grid, editProps, 'String', properties.ColumnSpan);
    
    uicontrol(grid, labelProps, 'String', 'Row span');
    rowSpanBox = uicontrol(grid, editProps, 'String', properties.RowSpan);
    
    % Borders
    uicontrol(grid, labelProps, 'String', 'Top border');
    borderTopBox = uicontrol(grid, editProps, 'String', properties.BorderTop);
    
    uicontrol(grid, labelProps, 'String', 'Right border');
    borderRightBox = uicontrol(grid, editProps, 'String', properties.BorderRight);

    uicontrol(grid, labelProps, 'String', 'Bottom border');
    borderBottomBox = uicontrol(grid, editProps, 'String', properties.BorderBottom);
    
    uicontrol(grid, labelProps, 'String', 'Left border');
    borderLeftBox = uicontrol(grid, editProps, 'String', properties.BorderLeft);
    
    uicontrol(grid, nb_constant.BUTTON, ...
        'string',             'OK',...
        'callback',           {@okCallback});
    
    uicontrol(grid, nb_constant.BUTTON, ...
        'string',             'Cancel',...
        'callback',           {@cancelCallback});
    
    set(figureHandle,'visible','on');
    
    % Callback functions
    function cancelCallback(~, ~, ~)
        close(figureHandle);
    end

    function okCallback(~, ~, ~)
        % TODO: Need 
        
        new.BackgroundColor = bgColors(get(backgroundColorBox, 'Value'), :);
        if isnan(new.BackgroundColor)
            new.BackgroundColor = [];
        end
        new.Color = fontColors(get(colorBox, 'Value'), :);
        if isnan(new.Color)
            new.Color = [];
        end
        new.DateFormat = dateFormats{get(dateFormatBox, 'Value')};
        new.FontWeight = fontWeights{get(fontWeightBox, 'Value')};
        new.Interpreter = fontInts{get(fontIntBox, 'Value')};
        new.HorizontalAlignment = horizontalAlignments{get(horizontalAlignmentBox, 'Value')};
        new.VerticalAlignment = verticalAlignments{get(verticalAlignmentBox, 'Value')};
        new.BorderTop = str2num(get(borderTopBox, 'String')); %#ok<*ST2NM>
        new.BorderRight = str2num(get(borderRightBox, 'String'));
        new.BorderBottom = str2num(get(borderBottomBox, 'String'));
        new.BorderLeft = str2num(get(borderLeftBox, 'String'));
        new.ColumnSpan = str2num(get(columnSpanBox, 'String'));
        new.RowSpan = str2num(get(rowSpanBox, 'String'));
        
        unchangedFields = {};
        for f = fieldnames(new)'
            field = f{1};
            if isequal(new.(field), properties.(field))
                unchangedFields = [unchangedFields, field]; %#ok<AGROW>
            end
        end
        new = rmfield(new, unchangedFields);

        switch lower(range)
            case 'table'
                obj.cells(:, :) = nb_table.mergeCells(obj.cells(:, :), new, 'overwrite');
            case 'row'
                obj.cells(y, :) = nb_table.mergeCells(obj.cells(y,:), new, 'overwrite');
            case 'column'
                obj.cells(:, x) = nb_table.mergeCells(obj.cells(:, x), new, 'overwrite');
            otherwise
                obj.cells(y, x) = nb_table.mergeCells(obj.cells(y, x), new, 'overwrite');
        end

        close(figureHandle);
        obj.update();

    end
end

function colors = htmlColors(endc)
% Create a color list for use in colored pop-up menus

    colors = cell(size(endc,1),1);
    for a = 1:size(endc,1)
        colors{a} = ['<HTML><BODY bgcolor="rgb(' num2str(endc(a,1)*255) ',' ...
                     num2str(endc(a,2)*255) ',' num2str(endc(a,3)*255) ')">  '...
                    '    <PRE>                  </PRE></BODY></HTML>'];
    end
    
end

function properties = getCommonProperties(cells)
% Get property values where all selected cells agree
    properties = cells(1);
    fields = fieldnames(properties);
    
    for i = 1:length(fields)
        field = fields{i};
        values = {cells.(field)};
        
        try %#ok
            values = lower(values);
        end
        
        if ~isequal(values{:})
            properties.(field) = [];
        end
    end
end


