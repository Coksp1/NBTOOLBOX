function editSpace(gui,hObject,~)
% Syntax:
%
% editSpace(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set space option of the legend callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    if isnan(value)
        value = [];
    end
    
    % Assign graph object
    gui.plotter.legSpace = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
