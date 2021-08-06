function onMouseMove(obj, ~, ~)

    [rowDivider, columnDivider] = obj.getHoveredDividers();  
    if (~isempty(rowDivider) || ~isempty(obj.selectedRowDivider))
        set(obj.parent.parent.figureHandle, 'pointer', 'bottom');
    elseif (~isempty(columnDivider) || ~isempty(obj.selectedColumnDivider))
        set(obj.parent.parent.figureHandle, 'pointer', 'left');
    end

end
