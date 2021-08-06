function deleteRow(obj, y)
% Delete row number y

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    assert(...
        nb_iswholenumber(y) && ...
        (y > 0) && (y <= obj.size(1)), ...
        ['Row number ' toString(y) ' does not exist']);
    
    % Delete graphic objects
    graphicHandles = struct2cell([obj.cells(y, :).graphicHandles]);
    for handle = [graphicHandles{:}]
        if ishandle(handle)
           delete(handle);
       end
    end

    obj.cells(y, :) = [];
    
    % Re-normalize row sizes
    obj.RowSizes(y) = [];
    obj.RowSizes = obj.RowSizes / sum(obj.RowSizes);
    
    obj.update();

end
