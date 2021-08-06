function updateFormat(gui,format)

    index = gui.index;
    switch lower(gui.type)
        
        case 'all'
            
            set(gui.parent,'formatAll',format)
            
        case 'column'
            
            fColumns = gui.parent.formatColumns;
            if isempty(fColumns)
                fColumns = {format};
            else
                ind      = [fColumns{:}];
                ind      = reshape([ind(:).index],[2,length(fColumns)])';
                ind      = find(ind(:,1) == index(1) & ind(:,2) == index(3),1,'last');
                if isempty(ind)
                    fColumns = [fColumns,{format}];
                else
                    fColumns{ind} = format;
                end
            end
            set(gui.parent,'formatColumns',fColumns)
            
        case 'row'
            
            fRows = gui.parent.formatRows;
            if isempty(fRows)
                fRows = {format};
            else
                ind   = [fRows{:}];
                ind   = reshape([ind(:).index],[2,length(fRows)])';
                ind   = find(ind(:,1) == index(2) & ind(:,2) == index(3),1,'last');
                if isempty(ind)
                    fRows = [fRows,{format}];
                else
                    fRows{ind} = format;
                end
            end
            set(gui.parent,'formatRows',fRows)
            
        case 'cell'
            
            fCells = gui.parent.formatCells;
            if isempty(fCells)
                fCells = {format};
            else
                ind    = [fCells{:}];
                ind    = reshape([ind(:).index],[3,length(fCells)])';
                ind    = find(ind(:,1) == index(1) & ind(:,2) == index(2) & ind(:,3) == index(3),1,'last');
                if isempty(ind)
                    fCells = [fCells,{format}];
                else
                    fCells{ind} = format;
                end
            end
            set(gui.parent,'formatCells',fCells)
            
    end
    notify(gui.parent,'annotationEdited')

end
