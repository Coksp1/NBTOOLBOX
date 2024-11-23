function setNoTitle(gui,hObject,~)
% Syntax:
%
% setNoTitle(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    gui.plotter.noTitle = nb_getUIControlValue(hObject);

    % Notify listeners
    notify(gui,'changedGraph');

end
