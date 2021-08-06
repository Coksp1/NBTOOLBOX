function getSelectedCells(gui,~,event)
% Syntax:
%
% getSelectedCells(gui,hObject,event)
%
% Description:
%
% Part of DAG. Get selected cells.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % First column: selected date indexes
    % Second column: selected variables indexes
    gui.selectedCells = event.Indices;

end
