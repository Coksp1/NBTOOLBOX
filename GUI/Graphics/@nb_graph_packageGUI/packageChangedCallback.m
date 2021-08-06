function packageChangedCallback(gui,~,~)
% Syntax:
%
% packageChangedCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.changed = 1;
    notify(gui,'changedGraphs');

end
