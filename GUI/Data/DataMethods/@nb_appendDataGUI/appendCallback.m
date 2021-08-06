function appendCallback(gui,hObject,~)
% Syntax:
%
% appendCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    value = get(gui.appendType,'value');
    switch value
        case 1
            type = '';
        case 2
            type = 'levelGrowth';
        case 3
            type = 'levelLevel';
    end
    
    try
        gui.data = append(gui.data1,gui.data2,'','','',type);
    catch %#ok<CTCH>
        nb_errorWindow('Cannot append the two datasets.');
        return
    end
    storeToGUI(gui)
    
    % Close window
    delete(get(hObject,'parent'))

end
