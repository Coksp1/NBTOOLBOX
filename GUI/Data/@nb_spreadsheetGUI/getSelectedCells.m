function getSelectedCells(gui,~,event)
% Syntax:
%
% getSelectedCells(gui,hObject,event)
%
% Description:
%
% Part of DAG. Get selected cells
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    sel                = event.Indices;
    gui.selectedCellsU = sel;
    if ~isa(gui.data,'nb_modelDataSource') && gui.data.isDistribution
        gui.selectedCells = sel;
    else
        row               = [min(sel(:,1)),max(sel(:,1))];
        col               = [min(sel(:,2)),max(sel(:,2))];
        gui.selectedCells = [row;col];
    end
    
    notify(gui,'selectionChanged');

end
