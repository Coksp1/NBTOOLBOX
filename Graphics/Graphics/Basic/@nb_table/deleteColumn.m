function deleteColumn(obj, x)
% Delete column number x

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    assert(...
        nb_iswholenumber(x) && ...
        (x > 0) && (x <= obj.size(2)), ...
        ['Column number ' toString(x) ' does not exist']);
    
    % Delete graphic objects
    graphicHandles = struct2cell([obj.cells(:, x).graphicHandles]);
    for handle = [graphicHandles{:}]
        if ishandle(handle)
           delete(handle);
       end
    end

    obj.cells(:, x) = [];
    
    % Re-normalize columns sizes
    obj.ColumnSizes(x) = [];
    obj.ColumnSizes = obj.ColumnSizes / sum(obj.ColumnSizes);
    
    obj.update();

end
