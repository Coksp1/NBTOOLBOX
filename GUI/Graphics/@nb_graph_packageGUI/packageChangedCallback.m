function packageChangedCallback(gui,~,~)
% Syntax:
%
% packageChangedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    gui.changed = 1;
    notify(gui,'changedGraphs');

end
