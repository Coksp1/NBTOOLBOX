function getSelectedCells(gui,~,event)
% Get selected cells

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    sel               = event.Indices;
    row               = [min(sel(:,1)),max(sel(:,1))];
    col               = [min(sel(:,2)),max(sel(:,2))];
    gui.selectedCells = [row;col];

end
