function updateGUI(gui, varargin)
% Syntax:
%
% updateGUI(gui, varargin)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    distributionNames = reshape({gui.distributions.name}, size(gui.distributions));
    set(gui.tableHandle, ...
        'ColumnName',       gui.variables, ...
        'RowName',          gui.dates, ...
        'Data',             distributionNames, ...
        'ColumnEditable',   false);
    
end
