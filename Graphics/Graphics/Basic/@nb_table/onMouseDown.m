function onMouseDown(obj, ~, ~)

    % Row and/or column dividers
    [obj.selectedRowDivider, obj.selectedColumnDivider] = obj.getHoveredDividers();
    if (~isempty(obj.selectedRowDivider) || ~isempty(obj.selectedColumnDivider))
        [~, obj.selectionStartPosition] = nb_getCurrentPointInAxesUnits(obj.parent.parent, obj.parent);
    end
    
end
