function transposeCallback(gui,~,~)
% Syntax:
%
% transposeCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Function called when transpose button is pressed. Transposes imported 
% data.
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Transpose data
    gui.dataC = gui.dataC';

    % Update table data
    updateTable(gui);
    
end

