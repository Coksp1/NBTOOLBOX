function overwrite(gui,hObject,~)
% Syntax:
%
% overwrite(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the already stored data
    appData = gui.parent.data;

    % Overwrite existing dataset
    appData.(gui.name) = gui.data;

    % Assign it to the main GUI object so I can use it later
    gui.parent.data = appData;

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));

end
