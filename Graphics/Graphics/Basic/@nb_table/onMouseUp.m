function onMouseUp(obj, ~, ~)
    % Anything selected?
    if isempty(obj.selectionStartPosition)
        return
    end

    [~, mousePosition] = nb_getCurrentPointInAxesUnits(obj.parent.parent, obj.parent);
    movement = mousePosition - obj.selectionStartPosition;
    
    if (obj.selectedRowDivider == 1)
        resizeParent(obj,[0 movement(2)], 'bottom');
    elseif (obj.selectedRowDivider == obj.size(1) + 1)
        resizeParent(obj,[0 movement(2)], 'top');
    elseif ~isempty(obj.selectedRowDivider)
        rowNumber = obj.size(1) + 1 - obj.selectedRowDivider;
        resizeRow(obj,rowNumber, movement(2)); 
    end
    
    if (obj.selectedColumnDivider == 1)
        resizeParent(obj,[movement(1) 0], 'left');
    elseif (obj.selectedColumnDivider == obj.size(2) + 1)
        resizeParent(obj,[movement(1) 0], 'right');
    elseif ~isempty(obj.selectedColumnDivider)
        resizeColumn(obj,obj.selectedColumnDivider, movement(1));
    end

    % Reset
    obj.selectedRowDivider = [];
    obj.selectedColumnDivider = [];
    
    
end

% Sub functions
%==========================================================================
function resizeRow(obj,rowNumber, change)

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Restrict change
    minRowHeight = 0.02;
    change       = min(change, obj.RowSizes(rowNumber) - minRowHeight);

    switch lower(obj.mode)

        case 'neighbour'

            change = max(change, -(obj.RowSizes(rowNumber + 1) - minRowHeight));

            % Perform change
            obj.RowSizes(rowNumber)     = obj.RowSizes(rowNumber) - change;
            obj.RowSizes(rowNumber + 1) = obj.RowSizes(rowNumber + 1) + change;

            % Redraw affected cells
            obj.update(rowNumber:rowNumber + 1, []);

        otherwise

            % Secure that no row gets to small
            num = obj.size(1) - 1;
            if rowNumber == obj.size(1)
                index  = 1:obj.size(1)-1;
                indexA = obj.size(1);
            else
                index  = [1:rowNumber-1,rowNumber+1:num+1];
                indexA = rowNumber;
                change = -change;
            end
            rows    = obj.RowSizes(index);
            problem = rows - change/num <= minRowHeight;
            part    = sum(rows(problem)-minRowHeight);
            indexP  = index(problem);
            index   = index(~problem);
            count   = length(index);
            changeD = (change-part)/count;

            % Perform change
            obj.RowSizes(indexA) = obj.RowSizes(indexA) + change;
            obj.RowSizes(index)  = obj.RowSizes(index) - changeD;
            obj.RowSizes(indexP) = minRowHeight;

            % Robustify
            ind = obj.RowSizes < minRowHeight;
            if  any(ind)
                resizeRowIterion(obj,minRowHeight,ind);
            end

            % Redraw affected cells
            obj.update([], []);

    end

end

function resizeColumn(obj,columnNumber, change)

    % Restrict change
    minColWidth = 0.02;
    change      = min(change, obj.ColumnSizes(columnNumber) - minColWidth);

    switch lower(obj.mode)

        case 'neighbour'

            change = max(change, -(obj.ColumnSizes(columnNumber + 1) - minColWidth));

            % Perform change
            obj.ColumnSizes(columnNumber)     = obj.ColumnSizes(columnNumber) - change;
            obj.ColumnSizes(columnNumber + 1) = obj.ColumnSizes(columnNumber + 1) + change;

            % Redraw affected cells
            obj.update(columnNumber:columnNumber + 1, []);

        otherwise

            columnNumber = columnNumber - 1;

            % Secure that no row gets to small
            num = obj.size(2) - 1;
            if columnNumber == 1
                index  = 2:obj.size(2);
                indexA = 1;
            else
                index  = [1:columnNumber,columnNumber+2:num+1];
                indexA = columnNumber + 1;
                change = -change;
            end
            cols    = obj.ColumnSizes(index);
            problem = cols - change/num <= minColWidth;
            part    = sum(cols(problem)-minColWidth);
            indexP  = index(problem);
            index   = index(~problem);
            count   = length(index);
            changeD = (change-part)/count;

            % Perform change
            obj.ColumnSizes(indexA) = obj.ColumnSizes(indexA) + change;
            obj.ColumnSizes(index)  = obj.ColumnSizes(index) - changeD;
            obj.ColumnSizes(indexP) = minColWidth;

            % Robustify
            ind = obj.ColumnSizes < minColWidth;
            if any(ind)
                resizeColumnIterion(obj,minColWidth,ind);
            end

            % Redraw affected cells
            obj.update([], []);

    end

end

function resizeColumnIterion(obj,crit,ind)

    changeE               = sum(-(obj.ColumnSizes(ind) - crit));
    obj.ColumnSizes(~ind) = obj.ColumnSizes(~ind) - changeE/sum(~ind);
    obj.ColumnSizes(ind)  = crit;
    ind                   = obj.ColumnSizes < crit;
    if any(ind)
        resizeColumnIterion(obj,crit,ind)
    end

end

function resizeRowIterion(obj,crit,ind)

    changeE            = sum(-(obj.RowSizes(ind) - crit));
    obj.RowSizes(~ind) = obj.RowSizes(~ind) - changeE/sum(~ind);
    obj.RowSizes(ind)  = crit;
    ind                = obj.RowSizes < crit;
    if any(ind)
        resizeRowIterion(obj,crit,ind)
    end

end

function resizeParent(obj,change, direction)
    % TODO
end




