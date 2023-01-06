function pointer = changeMouse(obj)
% When the mouse moves on the figure this method will
% be called by the nb_figure parent.

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [rowDivider, columnDivider] = obj.getHoveredDividers();

    if (~isempty(rowDivider) || ~isempty(obj.selectedRowDivider))
        pointer = 'bottom';
    elseif (~isempty(columnDivider) || ~isempty(obj.selectedColumnDivider))
        pointer = 'left';
    else
        pointer = '';
    end

end
