function finishCallback(gui,~,~)
% Syntax:
%
% finishCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    gui.cstr = get(gui.listbox,'string');

    % Close window
    delete(gui.figureHandle);

    % Notify listener that the reordering is done.
    notify(gui,'reorderingFinished');
    
end
