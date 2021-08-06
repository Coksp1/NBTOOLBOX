function editSpace(gui,hObject,~)
% Syntax:
%
% editSpace(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set space option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
