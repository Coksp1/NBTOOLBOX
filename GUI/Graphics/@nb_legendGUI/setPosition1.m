function setPosition1(gui,hObject,~)
% Syntax:
%
% setPosition1(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set position option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    if isnan(value)
        set(hObject,'string','0.96');
        value = 0.96;
    end
    
    % Assign graph object
    gui.plotter.legPosition(1) = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
