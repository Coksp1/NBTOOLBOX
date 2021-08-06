function selectPageCallback(gui,~,~)
% Syntax:
%
% selectPageCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Get selected page callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    page = get(gui.popupmenu,'value');
    gui.plotter.set('page',page);
    
    % Notify listeners
    notify(gui,'changedGraph');

end
