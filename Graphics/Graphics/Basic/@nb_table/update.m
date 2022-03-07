function update(obj, yRange, xRange)
% Update cells
    % Avoid recursive calls to obj.update()
    %obj.updateOnChange = false;
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3 || isempty(xRange)
        xRange = 1:obj.size(2);
    end
    
    if nargin < 2 || isempty(yRange)
        yRange = 1:obj.size(1);
    end
    
    % Update context menu visibility   
    if obj.allowDimensionChange
        set(obj.contextMenuAdd, 'visible', 'on');
        set(obj.contextMenuDelete, 'visible', 'on');
    else
        set(obj.contextMenuAdd, 'visible', 'off');
        set(obj.contextMenuDelete, 'visible', 'off');
    end
    
    % Needed for margin calculations
    pointNormRatio = nb_unitsRatio('Points', 'Normalized', obj.axesHandle);
            
    % Apply pattern values to empty property values
    cells = obj.applyPatterns(obj.cells);
    
    commonProps = struct('Visible', 'on');
    
    for y = yRange
        for x = xRange

            properties     = cells(y, x);
            graphicHandles = properties.graphicHandles;
            cellPosition   = obj.getCellPosition(y, x, properties);

            % Background
            background = struct(...
                'Position', cellPosition,...
                'FaceColor', properties.BackgroundColor, ...
                'UserData', struct('TablePosition', [y x]));
            set(graphicHandles.background, commonProps, background);

            % Borders
            borderTop.XData = [cellPosition(1), cellPosition(1) + cellPosition(3)];
            borderTop.YData = [cellPosition(2) + cellPosition(4), cellPosition(2) + cellPosition(4)];
            borderTop.Color = obj.BorderColor;
            if (properties.BorderTop > 0)
                borderTop.LineStyle = '-';
                borderTop.LineWidth = properties.BorderTop;
            else
                borderTop.LineStyle = 'none';
            end
            set(graphicHandles.borderTop, commonProps, borderTop);

            borderRight.XData = [cellPosition(1) + cellPosition(3), cellPosition(1) + cellPosition(3)];
            borderRight.YData = [cellPosition(2), cellPosition(2) + cellPosition(4)];
            borderRight.Color = obj.BorderColor;
            if (properties.BorderRight > 0)
                borderRight.LineStyle = '-';
                borderRight.LineWidth = properties.BorderRight;
            else
                borderRight.LineStyle = 'none';
            end
            set(graphicHandles.borderRight, commonProps, borderRight);
            
            borderBottom.XData = [cellPosition(1), cellPosition(1) + cellPosition(3)];
            borderBottom.YData = [cellPosition(2), cellPosition(2)];
            borderBottom.Color = obj.BorderColor;
            if (properties.BorderBottom > 0)
                borderBottom.LineStyle = '-';
                borderBottom.LineWidth = properties.BorderBottom;
            else
                borderBottom.LineStyle = 'none';
            end
            set(graphicHandles.borderBottom, commonProps, borderBottom);
            
            borderLeft.XData = [cellPosition(1), cellPosition(1)];
            borderLeft.YData = [cellPosition(2), cellPosition(2) + cellPosition(4)];
            borderLeft.Color = obj.BorderColor;
            if (properties.BorderLeft > 0)
                borderLeft.LineStyle = '-';
                borderLeft.LineWidth = properties.BorderLeft;
            else
                borderLeft.LineStyle = 'none';
            end
            set(graphicHandles.borderLeft, commonProps, borderLeft);
            
            % Put spanning cells in front
            if (properties.ColumnSpan > 1 || properties.RowSpan > 1)
               handlesVector = struct2cell(graphicHandles);
               handlesVector = [handlesVector{:}];
               uistack(handlesVector, 'up', 9999);
            end
            
        end
    end
    
    % For some reason, rendering text elements separately
    % from other elements significantly improves performance
    for y = yRange
        for x = xRange
            
            properties     = cells(y, x);
            graphicHandles = properties.graphicHandles;
            cellPosition   = obj.getCellPosition(y, x, properties);

            % Add cursor '|' if currently editing
            if isequal(graphicHandles.text, obj.editedObject)
                line = properties.String{obj.editIndex(1)};
                properties.String{obj.editIndex(1)} = ...
                    [line(1:obj.editIndex(2)-1), '|', line(obj.editIndex(2):end)];
            end

            % Date format
            string = properties.String;
            if ~isempty(properties.DateFormat)
                try %#ok<TRYNC>
                    dateObj = nb_date.date2freq(string);
                    string  = nb_date.format2string(dateObj,properties.DateFormat,obj.language);
                    string  = {string}; 
                end
            end
            
            % Set properties
            set(graphicHandles.text, commonProps, ...
                'Color',                properties.Color, ...
                'HorizontalAlignment',  properties.HorizontalAlignment, ...
                'VerticalAlignment',    properties.VerticalAlignment, ...
                'Interpreter',          properties.Interpreter,...
                'FontName',             properties.FontName,...
                'fontUnits',            properties.FontUnits, ...
                'FontSize',             properties.FontSize, ...
                'FontWeight',           properties.FontWeight, ...
                'String',               string, ...
                'UserData',             struct('TablePosition', [y x]));

            % Margin in normalized units
            marginSize = pointNormRatio * properties.Margin;

            % Wrap text inside boundaries
            textBoundary    = get(graphicHandles.background, 'Position');
            textBoundary(1) = textBoundary(1) + marginSize(1);
            textBoundary(3) = textBoundary(3) - marginSize(1);
            nb_breakText(graphicHandles.text, textBoundary);

            % Calculate text position
            textPosition = [NaN NaN];
            switch lower(properties.HorizontalAlignment)
                case 'left'
                    textPosition(1) = cellPosition(1) + marginSize(1);
                case 'center'
                    textPosition(1) = cellPosition(1) + (cellPosition(3) / 2);
                case 'right'
                    textPosition(1) = cellPosition(1) + cellPosition(3) - marginSize(1);
            end
            
            switch lower(properties.VerticalAlignment)
                case {'top', 'cap'}
                    textPosition(2) = cellPosition(2) + cellPosition(4) - marginSize(2);
                case 'middle'
                    textPosition(2) = cellPosition(2) + (cellPosition(4) / 2);
                case {'bottom', 'baseline'}
                    textPosition(2) = cellPosition(2) + marginSize(2);
            end
            set(graphicHandles.text, 'Position', textPosition);
            
            % Check if text should be visible (sometimes in goes out of 
            % border, and makes a mess).
            visible = true;
            for ii = 1:x-1
                if cells(y, ii).ColumnSpan > x - ii
                    visible = false;
                end
            end
            for ii = 1:y-1
                if cells(ii, x).RowSpan > y + 1 - ii
                    visible = false;
                end
            end
            if ~visible
                set(graphicHandles.text,'visible','off');
            end
            
        end
    end
    
    % TODO: Higher intelligence needed
    if ~obj.firstPlot
        obj.notify('tableUpdate');
    end
    obj.firstPlot = false;
    
    %obj.updateOnChange = true; 
end

