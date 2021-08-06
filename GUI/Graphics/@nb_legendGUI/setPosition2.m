function setPosition2(gui,hObject,~)
% Syntax:
%
% setPosition2(gui,hObject,event)
%
% Description:
%
% Part of DAG.Set position option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

     % Get value selected
    string = get(hObject,'string');
    value  = str2double(string);
    
    if isnan(value)
        value = 0.04;
        set(hObject,'string','0.04');
    end
    
    % Assign graph object
    gui.plotter.legPosition(2) = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
