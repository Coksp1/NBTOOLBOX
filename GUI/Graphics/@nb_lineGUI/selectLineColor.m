function selectLineColor(gui,hObject,~)
% Syntax:
%
% selectLineColor(gui,hObject,event)
%
% Description:
%
% Part of DAG. Select color
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;

    % Get selected color
    endc  = nb_getGUIColorList(gui,parent);
    index = get(hObject,'value');
    color = endc{index};
    
    % Get selected line object
    index = get(gui.popupmenu1,'value');
    
    if strcmpi(gui.type,'horizontal')
        plotterT.horizontalLineColor{index} = color;
    elseif strcmpi(gui.type,'vertical')
        plotterT.verticalLineColor{index} = color;  
    else
        % Update here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end

    % Notify listeners
    notify(gui,'changedGraph');

end
