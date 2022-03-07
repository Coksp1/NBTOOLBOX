function format = getFormat(gui)

    xx = gui.index(1);
    yy = gui.index(2);
    hh = gui.index(3);

    format = gui.parent.formatAll;
    if strcmpi(gui.type,'all')
        return
    end
    
    fColumns = gui.parent.formatColumns;
    if isempty(fColumns)
        fColInd = nan(0,2);
    else
        fColInd = [fColumns{:}];
        fColInd = reshape([fColInd(:).index],[2,length(fColumns)])';
    end
    fRows    = gui.parent.formatRows;
    if isempty(fRows)
        fRowInd = nan(0,2);
    else
        fRowInd  = [fRows{:}];
        fRowInd  = reshape([fRowInd(:).index],[2,length(fRows)])';
    end
    fCells   = gui.parent.formatCells;
    if isempty(fCells)
        fCellInd = nan(0,3);
    else
        fCellInd = [fCells{:}];
        fCellInd = reshape([fCellInd(:).index],[3,length(fCells)])';
    end

    if ~strcmpi(gui.type,'row')
        indCol = find(xx == fColInd(:,1) & hh == fColInd(:,2),1,'last');
        if ~isempty(indCol)
            format = updateFormat(format,gui.parent.formatColumns{indCol});
        end
        if strcmpi(gui.type,'column')
            return
        end
    end
    
    indRow = find(yy == fRowInd(:,1) & hh == fRowInd(:,2),1,'last');
    if ~isempty(indRow)
        format = updateFormat(format,gui.parent.formatRows{indRow});
    end
    if strcmpi(gui.type,'row')
        return
    end
    
    indCell = find(xx == fCellInd(:,1) & yy == fCellInd(:,2) & hh == fCellInd(:,3),1,'last');
    if ~isempty(indCell)
        format = updateFormat(format,gui.parent.formatCells{indCell});
    end

end

%==========================================================================
function format = updateFormat(format,newFormat)

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    fields = fieldnames(newFormat);
    for ii = 1:length(fields)
        if ~isempty(newFormat.(fields{ii}))
            format.(fields{ii}) = newFormat.(fields{ii});
        end
    end
    
end
