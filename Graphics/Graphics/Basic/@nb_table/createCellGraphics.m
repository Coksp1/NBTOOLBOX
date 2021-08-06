function handles = createCellGraphics(obj)
% Create graphic objects needed for a single cell

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Increase performance by hiding
    % objects until all properties are set
    commonProps = struct(...
        'Parent',   obj.axesHandle, ...
        'Visible',  'off');

    % Background
    handles.background = rectangle(commonProps, ...
        'EdgeColor',     'none', ...
        'UIContextMenu', obj.contextMenu, ...
        'ButtonDownFcn', @obj.editText);

    % Text
    handles.text = text(commonProps, ...
        'HorizontalAlignment', 'center', ...
        'UIContextMenu', obj.contextMenu, ...
        'ButtonDownFcn', @obj.editText);

    % Borders
    handles.borderTop    = line(commonProps);
    handles.borderRight  = line(commonProps);
    handles.borderBottom = line(commonProps);
    handles.borderLeft   = line(commonProps);
    
end
