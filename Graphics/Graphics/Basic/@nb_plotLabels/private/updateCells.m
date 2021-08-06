function updateCells(obj)

    if isempty(obj.idX) || isempty(obj.idY)
        return
    end

    % Find the removed and possibly re-ordered variables
    [iX,indX] = ismember(obj.idXOld,obj.idX);
    [iY,indY] = ismember(obj.idYOld,obj.idY);
    removedX  = find(~iX);
    removedY  = find(~iY);
    keptX     = find(iX);
    keptY     = find(iY);
    
    % Check which cells formating to keep or re-order
    if ~isempty(obj.formatCells) 
        
        nCells = length(obj.formatCells);
        keep   = true(1,nCells);
        for ii = 1:nCells
            
            oldInd = obj.formatCells{ii}.index;
            if any(oldInd == removedY) || any(oldInd == removedX)
                keep(ii) = false;
            end
            if any(oldInd == keptY) && any(oldInd == keptX)
                obj.formatCells{ii}.index = [indX(oldInd),indY(oldInd)];
            end
            
        end
        obj.formatCells = obj.formatCells(keep);
        
    end
    
    % Check which rows formating to keep or re-order
    if ~isempty(obj.formatRows)
        
        nRows = length(obj.formatRows);
        keep  = true(1,nRows);
        for ii = 1:nRows
            
            oldInd = obj.formatRows{ii}.index;
            if any(oldInd == removedY)
                keep(ii) = false;
            end
            if any(oldInd == keptY)
                obj.formatRows{ii}.index = indY(oldInd);
            end
            
        end
        obj.formatRows = obj.formatRows(keep);
        
    end
    
    % Check which columns formating to keep or re-order
    if ~isempty(obj.formatColumns) 
        
        nCols = length(obj.formatColumns);
        keep  = true(1,nCols);
        for ii = 1:nCols
            
            oldInd = obj.formatColumns{ii}.index;
            if any(oldInd == removedX)
                keep(ii) = false;
            end
            if any(oldInd == keptX)
                obj.formatColumns{ii}.index = indX(oldInd);
            end
            
        end
        obj.formatColumns = obj.formatColumns(keep);
        
    end
    
end
