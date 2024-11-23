function format = getFormat(obj,xx,yy,hh,fColInd,fRowInd,fCellInd)

    format = obj.formatAll;
    indCol = find(xx == fColInd(:,1) & hh == fColInd(:,2),1,'last');
    if ~isempty(indCol)
        format = updateFormat(format,obj.formatColumns{indCol});
    end
    indRow = find(yy == fRowInd(:,1) & hh == fRowInd(:,2),1,'last');
    if ~isempty(indRow)
        format = updateFormat(format,obj.formatRows{indRow});
    end
    indCell = find(xx == fCellInd(:,1) & yy == fCellInd(:,2) & hh == fCellInd(:,3),1,'last');
    if ~isempty(indCell)
        format = updateFormat(format,obj.formatCells{indCell});
    end

end

%==========================================================================
function format = updateFormat(format,newFormat)

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    fields = fieldnames(newFormat);
    for ii = 1:length(fields)
        if ~isempty(newFormat.(fields{ii}))
            format.(fields{ii}) = newFormat.(fields{ii});
        end
    end
    
end
