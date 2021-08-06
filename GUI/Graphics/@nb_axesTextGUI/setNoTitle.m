function setNoTitle(gui,hObject,~)
% Syntax:
%
% setNoTitle(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.plotter.noTitle = nb_getUIControlValue(hObject);

    % Notify listeners
    notify(gui,'changedGraph');

end
