function sortCallback(gui,hObject,~)
% Syntax:
%
% sortCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the dimension
    list  = get(gui.popupmenu1,'string');
    index = get(gui.popupmenu1,'value');
    order = list{index};
    
    % Get the output type
    list      = get(gui.popupmenu2,'string');
    index     = get(gui.popupmenu2,'value');
    variable  = list{index};

    % Do the calculation
    if isa(gui.data,'nb_data')
        gui.data = sort(gui.data,order,variable);
    else % nb_cs
        gui.data = sort(gui.data,1,order,variable);
    end

    % Close window
    delete(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end  
