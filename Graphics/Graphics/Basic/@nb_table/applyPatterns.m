function cells = applyPatterns(obj, cells)
% Create cells struct out of template specification
    patterns = obj.stylingPatterns;
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for i = 1:length(patterns)
        pattern = patterns(i).pattern;
        direction = patterns(i).direction;
        startIndex = patterns(i).startIndex;
        if isempty(pattern)
            pattern = struct;
        end

        % Repeat pattern
        if strcmpi(direction, 'right')
            pattern = repmat(pattern, 1, ceil(size(cells, 2) ./ size(pattern, 2)));
        elseif strcmpi(direction, 'down')
            pattern = repmat(pattern, ceil(size(cells, 1) ./ size(pattern, 1)), 1);
        else
            pattern = repmat(pattern, ceil(size(cells) ./ size(pattern)));
        end
        
        % Parse startIndex
        if isempty(startIndex)
            startIndex = [1 1];
        end
        
        if startIndex(1) <= 0
            startIndex(1) = size(cells, 1) + startIndex(1);
        end
        
        if startIndex(2) <= 0
            startIndex(2) = size(cells, 2) + startIndex(2);
        end
        
        yRange = startIndex(1):min(size(cells, 1), size(pattern, 1) + startIndex(1) - 1);
        xRange = startIndex(2):min(size(cells, 2), size(pattern, 2) + startIndex(2) - 1);
        cells(yRange, xRange) = nb_table.mergeCells(cells(yRange, xRange), pattern);
    end
    
    % Fallback values
    defaultCells = repmat(nb_table.defaultCellStyles, obj.size);
    cells = nb_table.mergeCells(cells, defaultCells);
    
end
