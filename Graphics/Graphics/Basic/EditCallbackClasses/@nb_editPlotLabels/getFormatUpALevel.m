function format = getFormatUpALevel(gui)

    xx = gui.index(1);
    yy = gui.index(2);
    hh = gui.index(3);

    format = gui.parent.formatAll;
    if ~strcmpi(gui.type,'cell')
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

    indCol = find(xx == fColInd(:,1) & hh == fColInd(:,2),1,'last');
    if ~isempty(indCol)
        format = updateFormat(format,gui.parent.formatColumns{indCol});
    end
    
    indRow = find(yy == fRowInd(:,1) & hh == fRowInd(:,2),1,'last');
    if ~isempty(indRow)
        format = updateFormat(format,gui.parent.formatRows{indRow});
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
