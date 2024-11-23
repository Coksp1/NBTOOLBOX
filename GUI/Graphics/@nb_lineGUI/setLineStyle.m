function setLineStyle(gui,hObject,~)
% Syntax:
%
% setLineStyle(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected color
    lineStyles = get(hObject,'string');
    index      = get(hObject,'value');
    lineStyle  = lineStyles{index};
    
    % Get selected line object
    index = get(gui.popupmenu1,'value');
    
    if strcmpi(gui.type,'horizontal')
        plotterT.horizontalLineStyle{index} = lineStyle;
    elseif strcmpi(gui.type,'vertical')
        plotterT.verticalLineStyle{index} = lineStyle;  
    else
        % Update here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end

    % Notify listeners
    notify(gui,'changedGraph');

end
