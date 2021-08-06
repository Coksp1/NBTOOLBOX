function getSelectedCells(gui,~,event)
% Syntax:
%
% getSelectedCells(gui,hObject,event)
%
% Description:
%
% Part of DAG. Get selected cells of table.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    sel               = event.Indices;
    row               = [min(sel(:,1)),max(sel(:,1))];
    col               = [min(sel(:,2)),max(sel(:,2))];
    gui.selectedCells = [row;col];

end
