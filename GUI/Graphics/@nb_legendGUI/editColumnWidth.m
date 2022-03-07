function editColumnWidth(gui,hObject,~)
% Syntax:
%
% editColumnWidth(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set column width option of the legend callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    if isnan(value)
        value = [];
    end
    
    % Assign graph object
    gui.plotter.legColumnWidth = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
