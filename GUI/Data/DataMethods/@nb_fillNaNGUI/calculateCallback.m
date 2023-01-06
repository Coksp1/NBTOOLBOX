function calculateCallback(gui,hObject,~)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if get(gui.components.radio1,'value')
        date = nb_getUIControlValue(gui.components.edit1,'numeric');
        if isnan(date)
            nb_errorWindow('The selected number of period must be an integer.')
            return
        elseif ~nb_isScalarInteger(date)
            nb_errorWindow('The selected number of period must be an integer.')
            return
        end
    else
        date           = nb_getUIControlValue(gui.components.edit1);
        [date,message] = nb_interpretDateObsTypeInputDataGUI(gui.data,date);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
    end
    
    % Evaluate the expression
    try
        gui.data = gui.data.fillNaN(date);
    catch Err
        nb_errorWindow(Err.message)
    end
        
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(get(hObject,'parent'));

end  
