function removeFormat(gui)

    index = gui.index;
    switch lower(gui.type)
        
        case 'column'
            
            fColumns = gui.parent.formatColumns;
            ind      = [fColumns{:}];
            ind      = reshape([ind(:).index],[2,length(fColumns)])';
            ind      = ind(:,1) == index(1) & ind(:,2) == index(3);
            set(gui.parent,'formatColumns', fColumns(~ind));
                          
        case 'row'
            
            fRows = gui.parent.formatRows;
            ind   = [fRows{:}];
            ind   = reshape([ind(:).index],[2,length(fRows)])';
            ind   = ind(:,1) == index(2) & ind(:,2) == index(3);
            set(gui.parent,'formatRows', fRows(~ind));
            
        case 'cell'
            
            fCells = gui.parent.formatCells;
            ind    = [fCells{:}];
            ind    = reshape([ind(:).index],[3,length(fCells)])';
            ind    = ind(:,1) == index(1) & ind(:,2) == index(2) & ind(:,3) == index(3);
            set(gui.parent,'formatCells', fCells(~ind));
            
    end
    
    notify(gui.parent,'annotationEdited')
    
end
