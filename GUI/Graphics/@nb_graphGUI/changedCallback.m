function changedCallback(gui,~,~)
% Syntax:
%
% changedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if gui.changed
        return
    end

    % Add a dot when changed
    gui.changed = 1;
    
end
