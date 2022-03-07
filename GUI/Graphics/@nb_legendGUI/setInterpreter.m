function setInterpreter(gui,hObject,~)
% Syntax:
%
% setInterpreter(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set interpreter option of the legend callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    index  = get(hObject,'value');
    value  = string{index};
    
    % Assign graph object
    gui.plotter.legInterpreter = value;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
