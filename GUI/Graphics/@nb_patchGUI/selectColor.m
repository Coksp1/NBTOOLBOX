function selectColor(gui,hObject,~)
% Syntax:
%
% selectColor(gui,hObject,event)
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
    plotterT.patch{index*4} = color;
    
    % Notify listeners
    notify(gui,'changedGraph')

end
