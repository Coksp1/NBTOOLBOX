% Work in progress
function colormap(obj)
    bgColors = obj.BackgroundColor;
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    strings = obj.String;
    numbers = cellfun(@str2double, strings, 'UniformOutput', false);
    numbers = cell2mat(numbers);
    
    % Map to colors
    newBgColors = matrix2color(numbers);
    
    for y = 1:size(newBgColors, 1)
        for x = 1:size(newBgColors, 2)
            if ~isnan(newBgColors{y, x})
                bgColors{y, x} = newBgColors{y, x};
            end
        end
    end
    
    obj.BackgroundColor = bgColors;
end

function colors = matrix2color(data)
    data = abs(data);
    data = (data - min(data(:))) / (max(data(:)) - min(data(:)));
    colors = arrayfun(@value2color, data, 'UniformOutput', false);
end

function rgb = value2color(value, colors)
    if isnan(value)
        rgb = NaN;
        return;
    end
    
    % Red => Yellow => Green
    colors = {[1 0 0], [1 1 0], [0 1 0]};

    fraction = 0;

    if(value <= 0)
        color1 = colors{1};
        color2 = colors{1};
    elseif (value >= 1)
        color1 = colors{end};
        color2 = colors{end};
    else
        colorIndex = value * (length(colors) - 1) + 1;
        color1 = colors{floor(colorIndex)};              
        color2 = colors{ceil(colorIndex)};
        fraction = colorIndex - floor(colorIndex);
    end

    rgb = (1 - fraction) * color1 + fraction * color2;
end
