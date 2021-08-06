function setValue(gui,hObject,~,type)
% Syntax:
%
% setValue(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if type == 1
        m = 2;
    else
        m = 1;
    end

    plotterT = gui.plotter;

    % Get selected color
    string = get(hObject,'string');
    ind    = get(hObject,'value');
    var    = string{ind};
    
    % Get selected line object
    index = get(gui.popupmenu1,'value');
    
    % Update the graph object
    plotterT.patch{index*4 - m} = var;
    
    % Notify listeners
    notify(gui,'changedGraph')

end
