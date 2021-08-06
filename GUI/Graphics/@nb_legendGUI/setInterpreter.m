function setInterpreter(gui,hObject,~)
% Syntax:
%
% setInterpreter(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set interpreter option of the legend callback
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legInterpreter = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
