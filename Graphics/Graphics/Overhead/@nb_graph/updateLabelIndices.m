function [fCells,fColumns,fRows] = updateLabelIndices(obj,ann)
% Syntax:
%
% [fCells,fColumns,fRows] = updateLabelIndices(obj,ann)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get current formatting 
    fCells   = ann.formatCells;
    fColumns = ann.formatColumns;
    fRows    = ann.formatRows;

    % Get variables plotted on each of the children of the nb_axes object
    %--------------------------------------------------------------------
    if isempty(obj.labelVariablesX)
        [obj.labelVariablesX,obj.labelVariablesY] = getLabelVariables(obj,0);
        return
    else
        [lVarsXNew,lVarsYNew] = getLabelVariables(obj,0);
    end

    % Get the index of new in old
    %-----------------------------
    lVarsXOld = obj.labelVariablesX;
    indXNew   = lVarsXOld;
    remXNew   = lVarsXOld;
    for ii = 1:length(lVarsXOld)
        [ind,loc]   = ismember(lVarsXOld{ii},lVarsXNew{ii});
        indXNew{ii} = loc;
        remXNew{ii} = find(~ind);
    end
    
    lVarsYOld = obj.labelVariablesY;
    indYNew   = lVarsYOld;
    remYNew   = lVarsYOld;
    for ii = 1:length(lVarsYOld)
        [ind,loc]   = ismember(lVarsYOld{ii},lVarsYNew{ii});
        indYNew{ii} = loc;
        remYNew{ii} = find(~ind);
    end
    
    % Adjsut or remove formatting
    %------------------------------
    if ~isempty(fCells)
        
        remove   = false(1,length(fCells));
        fCellInd = [fCells{:}];
        fCellInd = reshape([fCellInd(:).index],[3,length(fCells)])';
        for ii = 1:length(fCells)
           
            xx   = fCellInd(ii,1);
            yy   = fCellInd(ii,2);
            hh   = fCellInd(ii,3);
            remX = remXNew{hh};
            remY = remYNew{hh};
            if any(remX == xx) || any(remY == yy)
                remove(ii) = true;
            else
                xxn              = indXNew{hh}(xx);
                yyn              = indYNew{hh}(yy);
                fCells{ii}.index = [xxn,yyn,hh];
            end
            
        end
        fCells = fCells(~remove);
    
    end
    
    if ~isempty(fColumns)
    
        remove      = false(1,length(fColumns));
        fColumnsInd = [fColumns{:}];
        fColumnsInd = reshape([fColumnsInd(:).index],[2,length(fColumns)])';
        for ii = 1:length(fColumns)
           
            xx   = fColumnsInd(ii,1);
            hh   = fColumnsInd(ii,2);
            remX = remXNew{hh};
            if any(remX == xx)
                remove(ii) = true;
            else
                xxn                = indXNew{hh}(xx);
                fColumns{ii}.index = [xxn,hh];
            end
            
        end
        fColumns = fColumns(~remove);
        
    end
    
    if ~isempty(fRows)
    
        remove   = false(1,length(fRows));
        fRowsInd = [fRows{:}];
        fRowsInd = reshape([fRowsInd(:).index],[2,length(fRows)])';
        for ii = 1:length(fRows)
           
            yy   = fRowsInd(ii,1);
            hh   = fRowsInd(ii,2);
            remY = remYNew{hh};
            if any(remY == yy)
                remove(ii) = true;
            else
                yyn             = indYNew{hh}(yy);
                fRows{ii}.index = [yyn,hh];
            end
            
        end
        fRows = fRows(~remove);
        
    end
    
    % Update the label variables for next update
    obj.labelVariablesX = lVarsXNew;
    obj.labelVariablesY = lVarsYNew;

end
