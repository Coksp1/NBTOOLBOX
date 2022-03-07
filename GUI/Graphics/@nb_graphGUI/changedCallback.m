function changedCallback(gui,~,~)
% Syntax:
%
% changedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if gui.changed
        return
    end

    % Add a dot when changed
    gui.changed = 1;
    
end
