function cells = defaultCells(size)
    
    cells.String = cellstr('');
    cells.Editing = true; 
    cells.graphicHandles = struct(...
        'background',    NaN,...
        'text',          NaN,...
        'borderTop',     NaN,...
        'borderRight',   NaN,...
        'borderBottom',  NaN,...
        'borderLeft',    NaN);
    
    % Add style properties, but without any value
    styleProperties = fieldnames(nb_table.defaultCellStyles());
    for i = 1:length(styleProperties);
        cells.(styleProperties{i}) = [];
    end

    cells = repmat(cells, size);

end
