function finishCallback(gui,~,~)
% Syntax:
%
% finishCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string      = get(gui.listbox,'string');
    value       = get(gui.listbox,'value');
    gui.selcstr = string(value);
    
    % Close window
    delete(gui.figureHandle);

    % Notify listener that the reordering is done.
    notify(gui,'selectionFinished');
    
end
