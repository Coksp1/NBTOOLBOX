function plot(obj)
        
    % Get the parent to plot on
    %------------------------------------------------------
    ax = obj.parent;
    if isempty(ax)
        return
    end
    if ~isvalid(ax) 
        return
    end

    % Delete the old objects plotted by this object
    %--------------------------------------------------------------
    deleteChildren(obj)
    obj.children = [];

    % Get format and indices
    %-------------------------------------------------------------
    fColumns = obj.formatColumns;
    if isempty(fColumns)
        fColInd = nan(0,2);
    else
        fColInd = [fColumns{:}];
        fColInd = reshape([fColInd(:).index],[2,length(fColumns)])';
    end
    fRows    = obj.formatRows;
    if isempty(fRows)
        fRowInd = nan(0,2);
    else
        fRowInd  = [fRows{:}];
        fRowInd  = reshape([fRowInd(:).index],[2,length(fRows)])';
    end
    fCells   = obj.formatCells;
    if isempty(fCells)
        fCellInd = nan(0,3);
    else
        fCellInd = [fCells{:}];
        fCellInd = reshape([fCellInd(:).index],[3,length(fCells)])';
    end
    
    % Get the handle of the bar plot
    %------------------------------------------------------------------
    childs  = ax.children;
    nChilds = length(childs);

    % Get the data of the bar plot
    %--------------------------------------------------------------
    for hh = 1:nChilds

        if any(strcmpi(class(childs{hh}),{'nb_radar','nb_candle','nb_fanChart'}))
            continue
        end
        
        yData = childs{hh}.yData;
        for xx = 1:size(yData,1)
        
            for yy = 1:size(yData,2)
                
                format = getFormat(obj,xx,yy,hh,fColInd,fRowInd,fCellInd);
                if format.displayed
                    [xCor,yCor,string] = getCoordinatesAndString(obj,childs{hh},xx,yy,format);
                    if ~any(isnan([xCor,yCor]))
                        plotLabel(obj,xx,yy,hh,xCor,yCor,string,format,class(childs{hh}));
                    end
                end
                
            end
            
        end
        
    end
    
end
